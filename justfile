CACHE_DIR := ".cache"
FONT_VERSION := "7.9"
FONT_CACHE_DIR := CACHE_DIR / "fonts"
FONT_CACHE_FILE := FONT_CACHE_DIR / "MapleMono-v" + FONT_VERSION + ".zip"
FONT_CACHE_EXISTS := path_exists(FONT_CACHE_FILE)

@font:
    mkdir -p {{ FONT_CACHE_DIR }}
    {{ FONT_CACHE_EXISTS }} || \
        (wget https://github.com/subframe7536/maple-font/releases/download/v{{ FONT_VERSION }}/MapleMono-NF-CN-unhinted.zip -O {{ FONT_CACHE_FILE }} && \
        unzip -o {{ FONT_CACHE_FILE }} -d {{ FONT_CACHE_DIR }})

@font-version:
    echo "font-version={{ FONT_VERSION }}"
