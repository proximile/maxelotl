# Homebrew formula for maxelotl (a drop-in axel fork with long-URL support).
#
# Intended to live in a tap repository so users can:
#   brew install proximile/tap/maxelotl
#
# Installs `maxelotl` plus an `axel` alias. To set up the tap, create a public
# repo named "homebrew-tap" under the proximile account and drop this file in as
# Formula/maxelotl.rb. On each release, bump `url` to the new tag and update
# `sha256` to match the source tarball.
class Maxelotl < Formula
  desc "Drop-in axel download accelerator with long-URL support"
  homepage "https://github.com/proximile/maxelotl"
  url "https://github.com/proximile/maxelotl/archive/refs/tags/v2.18.0.tar.gz"
  sha256 "REPLACE_WITH_SOURCE_TARBALL_SHA256"
  license "GPL-2.0-or-later"
  head "https://github.com/proximile/maxelotl.git", branch: "main"

  depends_on "autoconf" => :build
  depends_on "autoconf-archive" => :build
  depends_on "automake" => :build
  depends_on "gettext" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "txt2man" => :build
  depends_on "openssl@3"

  def install
    # gettext keeps its m4 macros (AM_GNU_GETTEXT) under share/gettext/m4,
    # which is off aclocal's default search path; add it so autoreconf works.
    ENV.prepend_path "ACLOCAL_PATH", "#{Formula["gettext"].opt_share}/gettext/m4"
    system "autoreconf", "-fiv"
    system "./configure", "--disable-Werror", "--disable-nls",
           "SSL_PREFIX=#{Formula["openssl@3"].opt_prefix}",
           *std_configure_args
    system "make"
    # Install as `maxelotl` with an `axel` alias (drop-in replacement).
    bin.install "axel" => "maxelotl"
    bin.install_symlink "maxelotl" => "axel"
    man1.install "doc/axel.1" => "maxelotl.1"
  end

  test do
    assert_match "Axel", shell_output("#{bin}/maxelotl --version")
  end
end
