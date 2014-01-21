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
STAMP     = echo done >
SPLIT     = split -l $(LINESPROC) -d 

NPROC     = `nproc`

help:
	@echo "make all PHOTOS=<path> FPS=<default 15>"

dir:
	@if [ ! -d $(SRC) ]; then mkdir $(SRC); $(STAMP)dir.chg; fi
	@if [ ! -d $(RESIZED) ]; then mkdir $(RESIZED); $(STAMP)dir.chg; fi


cp_src: dir.chg dir
	@$(CP) $(PHOTOS) $(SRC)
	@$(STAMP)cp.chg

filelist: cp.chg
	@$(LS) $(SRC) | $(CUT) > $(FILES)

resize: filelist
	parallel -j $(NPROC) -i mogrify -path $(RESIZED) -resize 1920x1080! -rotate "-90<" {} -- $(SRC)/*.JPG

deflicker: 
	@echo "add deflicker"

fast: filelist
	cd $(RESIZED); \
	$(MENCODEC) $(FAST) -o $(OUTPUT) -mf fps=$(FPS) 'mf://@$(FILES)'

slow: filelist
	cd $(RESIZED); \
	$(MENCODEC) $(SLOW) -o $(OUTPUT) -mf fps=$(FPS) 'mf://@$(FILES)'

final: $(OUTPUT)
	avconv -i output.avi -c:v libx264 -preset slow -crf $(FPS) output-final.mkv

