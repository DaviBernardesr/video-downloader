# video-downloader

Script em Python para baixar vídeos do YouTube em **Full HD (1080p) MP4**, priorizando o codec **H.264** para máxima compatibilidade com qualquer player, TV ou celular.

## Windows — jeito fácil (1 clique)

1. Baixe a pasta do projeto (botão verde **Code → Download ZIP**) e extraia.
2. Dê **dois cliques** em **`Baixar Video.bat`**.

Não precisa instalar **nada** antes. Na primeira vez o `.bat` instala sozinho o que faltar:

- **Python** (instalador oficial, sem precisar de admin) — se ele instalar o Python, vai pedir pra você **fechar e abrir o programa de novo** uma vez;
- **yt-dlp** e **ffmpeg** (numa pasta `bin\` local).

Depois é só colar o link e apertar Enter. Pra baixar vários, ele pergunta "Baixar outro?" ao terminar.

---

## Requisitos (uso manual / macOS / Linux)

- Python 3
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) e [ffmpeg](https://ffmpeg.org/)

### Windows

No PowerShell:

```powershell
winget install yt-dlp.yt-dlp
winget install Gyan.FFmpeg
```

Depois **feche e abra o terminal de novo** (pro PATH atualizar). Se não tiver `winget`, dá pra usar `pip install yt-dlp` e instalar o ffmpeg manualmente.

### macOS

```bash
brew install yt-dlp ffmpeg
```

### Linux

```bash
sudo apt install yt-dlp ffmpeg     # ou: pip install yt-dlp
```

> Se faltar algo, o próprio script avisa e mostra o comando de instalação ao rodar.

## Uso

No Windows use `python`; no macOS/Linux use `python3`.

```bash
# por link
python baixar_video.py "https://youtu.be/xxxxx"

# por busca (baixa o primeiro resultado)
python baixar_video.py "henrique e juliano flor e o beija-flor"

# outra resolução (ex: 720p)
python baixar_video.py "<link>" -q 720

# outra pasta de destino
python baixar_video.py "<link>" -o "C:/Videos"      # Windows
python3 baixar_video.py "<link>" -o ~/Videos         # macOS/Linux
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
