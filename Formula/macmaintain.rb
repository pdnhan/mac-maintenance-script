class Macmaintain < Formula
  desc "Mac maintenance and optimization checker"
  homepage "https://github.com/pdnhan/mac-maintenance-script"
  url "https://github.com/pdnhan/mac-maintenance-script/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "PLACEHOLDER_REPLACE_WITH_ACTUAL_SHA256"
  license "MIT"

  depends_on "bash"

  def install
    bin.install "mac_maintenance.sh" => "macmaintain"
    man1.install "man/macmaintain.1"
  end

  test do
    assert_match "Mac Maintenance", shell_output("#{bin}/macmaintain --help")
  end
end