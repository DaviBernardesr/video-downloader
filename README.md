# video-downloader

Script em Python para baixar vídeos do YouTube em **Full HD (1080p) MP4**, priorizando o codec **H.264** para máxima compatibilidade com qualquer player, TV ou celular.

## Requisitos

- Python 3
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) e [ffmpeg](https://ffmpeg.org/)

No macOS (Homebrew):

```bash
brew install yt-dlp ffmpeg
```

## Uso

```bash
# por link
python3 baixar_video.py "https://youtu.be/xxxxx"

# por busca (baixa o primeiro resultado)
python3 baixar_video.py "henrique e juliano flor e o beija-flor"

# outra resolução (ex: 720p)
python3 baixar_video.py "<link>" -q 720

# outra pasta de destino (padrão: ~/Downloads/Videos)
python3 baixar_video.py "<link>" -o ~/Videos
```

## O que faz

| | |
|---|---|
| Resolução | até 1080p (Full HD) |
| Vídeo | H.264 (avc1) — cai para VP9/AV1 só se H.264 não existir |
| Áudio | AAC |
| Container | MP4 |
| Extras | capa (thumbnail) e metadados embutidos |

O YouTube hoje serve 1080p em AV1 por padrão (eficiente, mas players antigos não tocam). Por isso o script prioriza H.264, garantindo que o MP4 abra em qualquer lugar.

## Opções

| Opção | Descrição | Padrão |
|---|---|---|
| `fonte` | Link do vídeo ou texto para buscar | — |
| `-q`, `--qualidade` | Altura máxima em pixels | `1080` |
| `-o`, `--pasta` | Pasta de destino | `~/Downloads/Videos` |

---

Desenvolvido por Davi Bernardes.
