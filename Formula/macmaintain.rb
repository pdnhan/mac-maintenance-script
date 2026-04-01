class Macmaintain < Formula
  desc "Mac maintenance and optimization checker"
  homepage "https://github.com/pdnhan/mac-maintenance-script"
  url "https://github.com/pdnhan/mac-maintenance-script/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "10782b5b3d6f78772a323ed1f8ca11a82e84eb370424a4fb25ffeb6209ad360b"
  license "MIT"

  def install
    bin.install "mac_maintenance.sh" => "macmaintain"
    man1.install "man/macmaintain.1"
  end

  test do
    assert_match "Mac Maintenance", shell_output("#{bin}/macmaintain --help")
  end
end
