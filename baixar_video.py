#!/usr/bin/env python3
"""Baixa vídeos em Full HD (MP4) — script standalone (Windows, macOS e Linux).

Uso:
    python baixar_video.py "<link ou nome para buscar>"
    python baixar_video.py "https://youtu.be/xxxx"
    python baixar_video.py "henrique e juliano flor e o beija-flor"
    python baixar_video.py "<link>" -q 720          # outra resolução
    python baixar_video.py "<link>" -o "C:/Videos"   # outra pasta

(No macOS/Linux use python3 no lugar de python.)

Requisitos: yt-dlp e ffmpeg instalados (no PATH, ou numa pasta bin/ ao lado
do script). Rode o programa sem nada que ele mostra como instalar.
"""
from __future__ import annotations
import argparse
import os
import platform
import re
import shutil
import subprocess
import sys

_WINDOWS = platform.system() == "Windows"

# Console do Windows usa cp1252 e quebra com emojis/acentos — força UTF-8.
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass


def _get_bin(name: str) -> str:
    """Localiza um binário: bin/ ao lado do script → Homebrew → PATH."""
    exe = f"{name}.exe" if _WINDOWS else name
    local = os.path.join(os.path.dirname(os.path.abspath(__file__)), "bin", exe)
    if os.path.exists(local):
        return os.path.normpath(local)
    if platform.system() == "Darwin":
        brew = f"/opt/homebrew/bin/{name}"
        if os.path.exists(brew):
            return brew
    return shutil.which(name) or shutil.which(exe) or name


YTDLP      = _get_bin("yt-dlp")
FFMPEG     = _get_bin("ffmpeg")
FFMPEG_DIR = os.path.dirname(FFMPEG) if os.path.sep in FFMPEG else ""

_URL_RE = re.compile(r"^https?://", re.IGNORECASE)


def is_url(text: str) -> bool:
    return bool(_URL_RE.match(text.strip()))


def _found(resolved: str) -> bool:
    """True se o binário foi localizado (caminho completo), não só o nome."""
    return os.path.sep in resolved and os.path.exists(resolved)


def check_deps() -> bool:
    """Verifica yt-dlp e ffmpeg; se faltar, mostra como instalar e retorna False."""
    faltando = [n for n, p in (("yt-dlp", YTDLP), ("ffmpeg", FFMPEG)) if not _found(p)]
    if not faltando:
        return True

    print(f"❌ Não encontrei: {', '.join(faltando)}\n")
    print("Como instalar:")
    if _WINDOWS:
        print("  Windows (PowerShell, mais fácil):")
        print("    winget install yt-dlp.yt-dlp")
        print("    winget install Gyan.FFmpeg")
        print("  Depois FECHE e ABRA o terminal de novo (pro PATH atualizar).")
        print("  Alternativa: pip install yt-dlp  (ffmpeg ainda precisa ser instalado)")
    elif platform.system() == "Darwin":
        print("  macOS (Homebrew):  brew install yt-dlp ffmpeg")
    else:
        print("  Linux:  sudo apt install yt-dlp ffmpeg   (ou: pip install yt-dlp)")
    return False


def build_cmd(source: str, dest: str, height: int) -> list:
    """Monta o comando do yt-dlp para baixar em até `height`p, saída MP4."""
    # Prioriza H.264 (avc1) + AAC — MP4 compatível com qualquer player/TV.
    # Cai para outros codecs (VP9/AV1) só se H.264 não existir na resolução.
    fmt = (
        f"bestvideo[height<=?{height}][vcodec^=avc1]+bestaudio[ext=m4a]/"
        f"bestvideo[height<=?{height}][ext=mp4]+bestaudio[ext=m4a]/"
        f"bestvideo[height<=?{height}]+bestaudio/"
        f"best[height<=?{height}]/best"
    )
    target = source if is_url(source) else f"ytsearch1:{source}"

    cmd = [
        YTDLP,
        "--no-warnings", "--newline",
        "--no-playlist",
        "--format", fmt,
        "--merge-output-format", "mp4",
        "--embed-thumbnail",
        "--convert-thumbnails", "jpg",
        "--embed-metadata",
        "--output", os.path.join(dest, "%(title)s [%(height)sp].%(ext)s"),
    ]
    if FFMPEG_DIR:
        cmd += ["--ffmpeg-location", FFMPEG_DIR]
    cmd.append(target)
    return cmd


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Baixa vídeos em Full HD (MP4).",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("fonte", help="Link do vídeo ou texto para buscar no YouTube")
    parser.add_argument("-q", "--qualidade", type=int, default=1080,
                        help="Altura máxima em pixels (padrão: 1080 = Full HD)")
    parser.add_argument("-o", "--pasta", default=os.path.join("~", "Downloads", "Videos"),
                        help="Pasta de destino (padrão: ~/Downloads/Videos)")
    args = parser.parse_args()

    if not check_deps():
        return 1

    dest = os.path.expanduser(args.pasta)
    os.makedirs(dest, exist_ok=True)

    print(f"🎬 Qualidade alvo: até {args.qualidade}p  ·  Pasta: {dest}")
    if is_url(args.fonte):
        print(f"🔗 Baixando: {args.fonte}")
    else:
        print(f"🔎 Buscando e baixando: \"{args.fonte}\"")

    cmd = build_cmd(args.fonte, dest, args.qualidade)
    try:
        proc = subprocess.run(cmd)
    except FileNotFoundError:
        check_deps()
        return 1

    if proc.returncode == 0:
        print(f"\n✅ Concluído! Vídeo salvo em: {dest}")
        return 0
    print("\n❌ Falha no download.")
    return proc.returncode


if __name__ == "__main__":
    sys.exit(main())
