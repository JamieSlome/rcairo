require 'pkg-config'

class PkgConfigTest < Test::Unit::TestCase
  def setup
    @cairo = PackageConfig.new("cairo")
    @cairo_png = PackageConfig.new("cairo-png")
  end

  def test_exist?
    assert(system('pkg-config --exists cairo'))
    assert(@cairo.exist?)

    assert(system('pkg-config --exists cairo-png'))
    assert(@cairo_png.exist?)
  end

  def test_cflags
    assert_pkg_config("cairo", ["--cflags"], @cairo.cflags)
    assert_pkg_config("cairo-png", ["--cflags"], @cairo_png.cflags)
  end

  def test_cflags_only_I
    assert_pkg_config("cairo", ["--cflags-only-I"], @cairo.cflags_only_I)
    assert_pkg_config("cairo-png", ["--cflags-only-I"], @cairo_png.cflags_only_I)
  end

  def test_libs
    assert_pkg_config("cairo", ["--libs"], @cairo.libs)
    assert_pkg_config("cairo-png", ["--libs"], @cairo_png.libs)

    @cairo.msvc_syntax = true
    result = pkg_config("cairo", "--libs")
    msvc_result = result.gsub(/-lcairo\b/, "cairo.lib")
    assert_not_equal(msvc_result, result)
    assert_equal(msvc_result, @cairo.libs)
  end

  def test_libs_only_l
    assert_pkg_config("cairo", ["--libs-only-l"], @cairo.libs_only_l)
    assert_pkg_config("cairo-png", ["--libs-only-l"], @cairo_png.libs_only_l)

    @cairo_png.msvc_syntax = true
    result = pkg_config("cairo-png", "--libs-only-l")
    msvc_result = result.gsub(/-l(cairo|png12)\b/, '\1.lib')
    assert_not_equal(msvc_result, result)
    assert_equal(msvc_result, @cairo_png.libs_only_l)
  end

  def test_requires
    assert_equal([], @cairo.requires)
  end

  def test_requires_private
    assert_equal(["freetype2", "fontconfig", "libpng12", "xrender", "x11"],
                 @cairo.requires_private)
  end

  def test_version
    assert_pkg_config("cairo", ["--modversion"], @cairo.version)
  end

  private
  def pkg_config(package, *args)
    args = args.collect {|arg| arg.dump}.join(' ')
    `pkg-config #{args} #{package}`.strip
  end

  def assert_pkg_config(package, pkg_config_args, actual)
    result = pkg_config(package, *pkg_config_args)
    result = nil if result.empty?
    assert_equal(result, actual)
  end
end
