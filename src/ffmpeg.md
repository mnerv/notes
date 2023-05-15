# ffmpeg

## Crop and Scale

```
ffmpeg -i {input} -filter:v "crop=iw:iw/3:0:200,scale=900:300" -c:v libx264 -crf 18 -c:a copy {output}
```

## Convert to images

```sh
ffmpeg -i {video} -vf fps=1 %d.png
```

