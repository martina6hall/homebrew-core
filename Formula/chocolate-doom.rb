class ChocolateDoom < Formula
  desc "Accurate source port of Doom"
  homepage "https://www.chocolate-doom.org/"
  url "https://www.chocolate-doom.org/downloads/3.0.0/chocolate-doom-3.0.0.tar.gz"
  sha256 "73aea623930c7d18a7a778eea391e1ddfbe90ad1ac40a91b380afca4b0e1dab8"

  bottle do
    cellar :any
    sha256 "af7016b2d60ca7dd02d91287994633b2674436587464e824294dc930566ffef1" => :high_sierra
    sha256 "837b44e4c36513df3d615d02ce986119049e1188c975343476d84380e43b0a19" => :sierra
    sha256 "a853675774b68249fd1aedc56a7c796fbc3177f7b64fbff666d21efd4c711611" => :el_capitan
    sha256 "f9ced92d1e87ff88edb96f6c22303217f72dad16e4160d409f896367ea0d56f9" => :x86_64_linux
  end

  head do
    url "https://github.com/chocolate-doom/chocolate-doom.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "sdl2"
  depends_on "sdl2_net"
  depends_on "sdl2_mixer"
  depends_on "libsamplerate" => :recommended
  depends_on "libpng" => :recommended

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-sdltest"
    system "make", "install", "execgamesdir=#{bin}"
    (share/"applications").rmtree
    (share/"icons").rmtree
  end

  def caveats; <<~EOS
    Note that this formula only installs a Doom game engine, and no
    actual levels. The original Doom levels are still under copyright,
    so you can copy them over and play them if you already own them.
    Otherwise, there are tons of free levels available online.
    Try starting here:
      #{homepage}
    EOS
  end
end
