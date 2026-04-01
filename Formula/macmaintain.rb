class Macmaintain < Formula
  desc "Mac maintenance and optimization checker"
  homepage "https://github.com/pdnhan/mac-maintenance-script"
  url "https://github.com/pdnhan/mac-maintenance-script/archive/refs/tags/v1.0.5.tar.gz"
  sha256 "f6ca4a3740f1369999e243148c5a689d3fd336dcfa19fa7d9db73224d8e8140b"
  version "1.0.5"
  license "MIT"

  def install
    bin.install "mac_maintenance.sh" => "macmaintain"
    man1.install "man/macmaintain.1"
  end

  test do
    assert_match "Mac Maintenance", shell_output("#{bin}/macmaintain --help")
  end
end
