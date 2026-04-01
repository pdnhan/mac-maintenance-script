class Macmaintain < Formula
  desc "Mac maintenance and optimization checker"
  homepage "https://github.com/pdnhan/mac-maintenance-script"
  url "https://github.com/pdnhan/mac-maintenance-script/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "e4b479b989e569ef681d6b00d6750810565e41b231ab099890007dc22ffdeeb4"
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