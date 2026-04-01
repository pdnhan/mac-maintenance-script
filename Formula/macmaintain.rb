class Macmaintain < Formula
  desc "Mac maintenance and optimization checker"
  homepage "https://github.com/pdnhan/mac-maintenance-script"
  url "https://github.com/pdnhan/mac-maintenance-script/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "bda2de2c91578733e70aec2c21dad06253a0c922e31e878da70520b225a64503"
  license "MIT"

  def install
    bin.install "mac_maintenance.sh" => "macmaintain"
    man1.install "man/macmaintain.1"
  end

  test do
    assert_match "Mac Maintenance", shell_output("#{bin}/macmaintain --help")
  end
end
