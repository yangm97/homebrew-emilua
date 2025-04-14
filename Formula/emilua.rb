class Emilua < Formula
  desc "A cross-platform execution engine for LuaJIT with support for async IO and
flexible threading layout."
  homepage "https://emilua.org/"
  license  any_of: ["BSL-1.0", "MIT"]
  head "https://gitlab.com/emilua/emilua.git", branch: "emilua-0.11.x"

  depends_on "meson" => [:build, :test]
  depends_on "ninja" => [:build, :test]
  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "asciidoctor" => :build
  depends_on "gawk" => :build
  depends_on "re2c" => :build
  depends_on "gperf" => :build
  depends_on "cereal" => :build

  depends_on "fmt"
  depends_on "luajit"
  depends_on "serd"
  depends_on "sord"
  depends_on "ncurses"
  depends_on "openssl@3"

  def install
    system "meson", "setup", "build", *std_meson_args, "-Deintr_rtsigno=0", "-Ddefault_library=static", "-Db_ndebug=true"
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test32.lua").write <<~LUA
      if _CONTEXT ~= 'main' then
        local inbox = require 'inbox'
        print(inbox:receive())
        return
      end
      local guest = spawn_vm{
          module = '.',
          inherit_context = false,
      }
      guest:send('test')
    LUA

    assert_equal "test", shell_output("#{bin}/emilua test32.lua").strip
  end
end
