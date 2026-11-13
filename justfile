CACHE_DIR := ".cache"
FONT_CACHE_DIR := CACHE_DIR / "fonts"
FONT_CJ_VERSION := "7.9"
FONT_K_VERSION := "1.4.0"
FONT_K_DATE := "20261003"
FONT_CJ_FILE := FONT_CACHE_DIR / "MapleMono-v" + FONT_CJ_VERSION + ".zip"
FONT_K_FILE := FONT_CACHE_DIR / "D2Coding-v" + FONT_K_VERSION + ".zip"
FONT_CJ_EXISTS := path_exists(FONT_CJ_FILE)
FONT_K_EXISTS := path_exists(FONT_K_FILE)
FONT_VERSION := FONT_CJ_VERSION + "|" + FONT_K_VERSION

@font:
    mkdir -p {{ FONT_CACHE_DIR }}
    {{ FONT_CJ_EXISTS }} || \
        (wget https://github.com/subframe7536/maple-font/releases/download/v{{ FONT_CJ_VERSION }}/MapleMono-NF-CN-unhinted.zip -O {{ FONT_CJ_FILE }} && \
        unzip -o {{ FONT_CJ_FILE }} -d {{ FONT_CACHE_DIR }})
    {{ FONT_K_EXISTS }} || \
        (wget https://github.com/naver/d2-coding-font/releases/download/VER{{ FONT_K_VERSION }}/D2Coding-Ver{{ FONT_K_VERSION }}-{{ FONT_K_DATE }}.zip -O {{ FONT_K_FILE }} && \
        unzip -o {{ FONT_K_FILE }} -d {{ FONT_CACHE_DIR }} && \
        cp {{ FONT_CACHE_DIR }}/D2CodingLigature/* {{ FONT_CACHE_DIR }})

@font-version:
    echo "font-version={{ FONT_VERSION }}"

build: font
    mkdir -p output
    typst compile --font-path .cache/fonts CJK.typ output/CJK.pdf
