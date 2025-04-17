class Emilua < Formula
  desc "Cross-platform LuaJIT engine with async IO and flexible threading"
  homepage "https://emilua.org/"
  url "https://gitlab.com/emilua/emilua/-/archive/v0.11.3/emilua-v0.11.3.tar.gz"
  sha256 "9726354ec99f9f64a8693a0b5cda5703c0f245adcb402e7b77d673b17eab9126"
  license any_of: ["BSL-1.0", "MIT"]

  bottle do
    root_url "https://github.com/yangm97/homebrew-emilua/releases/download/emilua-0.11.3"
    sha256 cellar: :any, arm64_sequoia: "a63becfc9ab6b4ea98059a053f9a8eb4f1792acee2887cc76a9bdf35bd454fbe"
  end

  depends_on "asciidoctor" => :build
  depends_on "boost" => :build
  depends_on "cereal" => :build
  depends_on "cmake" => :build
  depends_on "gawk" => :build
  depends_on "gperf" => :build
  depends_on "meson" => [:build, :test]
  depends_on "ninja" => [:build, :test]
  depends_on "pkg-config" => :build
  depends_on "re2c" => :build

  depends_on "fmt"
  depends_on "luajit"
  depends_on "ncurses"
  depends_on "openssl@3"
  depends_on "serd"
  depends_on "sord"

  def install
    system "meson", "setup", "build", *std_meson_args, "-Deintr_rtsigno=0", "-Ddefault_library=static",
"-Db_ndebug=true"
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
