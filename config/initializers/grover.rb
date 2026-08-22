Grover.configure do |config|
  config.options = {
    executable_path: "/usr/bin/chromium",
    launch_args: [ "--no-sandbox", "--disable-setuid-sandbox", "--font-render-hinting=medium", "--lang=ja" ],
    display_url: "http://localhost",
    # 出力を横向きにする
    landscape: true,
    # 見えない余白を固定する（印刷範囲の調整）
    margin: {
      top: "10px",
      bottom: "10px",
      left: "10px",
      right: "10px"
    }
  }
end
