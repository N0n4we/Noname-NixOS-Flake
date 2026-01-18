#!/usr/bin/env bash

set -o pipefail

# 运行 Rofi 并捕获用户的完整输入
full_input=$(rofi -i -dmenu -p "" -location 2 -font "Noto Sans Mono CJK SC 32" -theme-str 'window { width: 60%; height: 105px; } entry { placeholder: "Nix Search (pkg|opt|hm|sty|mn)"; horizontal-align: 0.5; }')

# 如果用户按 Esc 取消，则退出脚本
if [[ -z "$full_input" ]]; then
    exit 0
fi

# 使用 'read' 命令优雅地分离命令和查询内容
read -r command query_string <<<"$full_input"

# 根据第一个词决定使用哪个 URL 和查询内容
case "$command" in
pkg)
    base_url="https://search.nixos.org/packages?channel=unstable&query="
    query="$query_string"
    ;;
opt)
    base_url="https://search.nixos.org/options?channel=unstable&query="
    query="$query_string"
    ;;
hm)
    base_url="https://home-manager-options.extranix.com/?release=master&query="
    query="$query_string"
    ;;
sty)
    base_url="https://nix-community.github.io/stylix/configuration.html?search="
    query="$query_string"
    ;;
mn)
    base_url="https://mynixos.com/search?q="
    query="$query_string"
    ;;
*)
    base_url="https://search.nixos.org/packages?channel=unstable&query="
    query="$full_input"
    ;;
esac

# 如果查询内容为空，则退出
if [[ -z "$query" ]]; then
    exit 0
fi

# 对查询内容进行 URL 编码，以安全地处理特殊字符 (如空格, &, + 等)
encoded_query=$(jq -sRr @uri <<<"$query")

# 使用 xdg-open 在默认浏览器中打开最终的 URL
echo "Opening: ${base_url}${encoded_query}" # 调试信息
xdg-open "${base_url}${encoded_query}"
