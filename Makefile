ROOT_DIR  = $(HOME)/timelapse

PHOTOS    = ~/Pictures
FPS       = 15

SRC       = $(ROOT_DIR)/src
RESIZED   = $(ROOT_DIR)/resized
FILES     = $(ROOT_DIR)/files.txt
OUTPUT    = $(ROOT_DIR)/output.avi

DEFLICKER = $(ROOT_DIR)/timelapse-deflicker.pl 

CP        = cp -rf
LS        = ls -ltr 
CUT       = grep "JPG" | cut -d' ' -f9
MENCODEC  = mencoder -idx -nosound -noskip -ovc lavc -lavcopts
FAST      = vcodec=mjpeg
SLOW      = vcodec=ljpeg

help:
	@echo "make all PHOTOS=<path> FPS=<default 15>"

dir:
	@if [ ! -d $(SRC) ]; then mkdir $(SRC); fi
	@if [ ! -d $(RESIZED) ]; then mkdir $(RESIZED); fi


cp_src: dir
	@$(CP) $(PHOTOS) $(SRC)

filelist: 
	@$(LS) $(SRC) | $(CUT) > $(FILES)

resize: filelist
	mogrify -path $(RESIZED) -resize 1920x1080! -rotate "-90<" $(SRC)/*.JPG
deflicker: 
	@echo "add deflicker"

fast: filelist
	$(MENCODEC) $(FAST) -o $(OUTPUT) -mf fps=$(FPS) 'mf://@$(FILES)'

slow: filelist
	$(MENCODEC) $(SLOW) -o $(OUTPUT) -mf fps=$(FPS) 'mf://@$(FILES)'

final: $(OUTPUT)
	avconv -i output.avi -c:v libx264 -preset slow -crf $(FPS) output-final.mkv

