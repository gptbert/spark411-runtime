#!/usr/bin/env python3
"""Helpers for matplotlib Chinese display and plotly default fonts."""
from __future__ import annotations

from pathlib import Path
from typing import Any

COMMON_CHINESE_FONT_FILES = [
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
    "/usr/share/fonts/opentype/noto/NotoSansCJKsc-Regular.otf",
    "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc",
    "/usr/share/fonts/truetype/arphic/ukai.ttc",
    "/System/Library/Fonts/PingFang.ttc",
    "/System/Library/Fonts/Hiragino Sans GB.ttc",
    "C:/Windows/Fonts/msyh.ttc",
    "C:/Windows/Fonts/simhei.ttf",
]

COMMON_FONT_NAMES = [
    "Noto Sans CJK SC",
    "Source Han Sans SC",
    "SimHei",
    "Microsoft YaHei",
    "WenQuanYi Zen Hei",
    "Arial Unicode MS",
]


def configure_matplotlib_chinese(font_path: str | None = None) -> str | None:
    import matplotlib
    from matplotlib import font_manager

    selected_font_name: str | None = None

    if font_path:
        path = Path(font_path)
        if path.exists():
            font_manager.fontManager.addfont(str(path))
            selected_font_name = font_manager.FontProperties(fname=str(path)).get_name()
    else:
        for candidate in COMMON_CHINESE_FONT_FILES:
            path = Path(candidate)
            if path.exists():
                font_manager.fontManager.addfont(str(path))
                selected_font_name = font_manager.FontProperties(fname=str(path)).get_name()
                break

    if selected_font_name is None:
        available = {f.name for f in font_manager.fontManager.ttflist}
        for candidate in COMMON_FONT_NAMES:
            if candidate in available:
                selected_font_name = candidate
                break

    if selected_font_name:
        matplotlib.rcParams["font.sans-serif"] = [selected_font_name] + COMMON_FONT_NAMES
    else:
        matplotlib.rcParams["font.sans-serif"] = COMMON_FONT_NAMES

    matplotlib.rcParams["axes.unicode_minus"] = False
    return selected_font_name


def get_plotly_layout_defaults(title: str | None = None, font_family: str | None = None, **kwargs: Any) -> dict[str, Any]:
    family = font_family or ", ".join(COMMON_FONT_NAMES)
    layout: dict[str, Any] = {
        "font": {"family": family},
    }
    if title is not None:
        layout["title"] = {"text": title}
    layout.update(kwargs)
    return layout
