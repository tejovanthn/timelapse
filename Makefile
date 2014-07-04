#
# Makefile for automated timelapse processing
# Author: Tejovanth N 
#
# Required:
# gcp        : sudo apt-get install gcp
# parallel   : sudo apt-get install parallel && sudo rm /etc/parallel/config 
# mogrify    : sudo apt-get install imagemagick
# perlmagick : sudo apt-get install perlmagick libfile-type-perl libterm-progressbar-perl
# mencoder   : sudo apt-get install mencoder
# avconv     : sudo apt-get install libav-tools
#
#

ROOT_DIR   = $(HOME)/timelapse

PHOTOS     = ~/Pictures
FPS        = 15
MODE       = fast 
DEFLICKER  = no

SRC        = $(ROOT_DIR)/src
RESIZED    = $(ROOT_DIR)/resized
FILES      = $(ROOT_DIR)/files.txt
OUTPUT     = $(ROOT_DIR)/output.avi

DEFLICKERD = $(ROOT_DIR)/deflicker

CP         = gcp -rf
LS         = ls -ltr 
CUT        = grep "JPG" | cut -d' ' -f10
MENCODEC   = mencoder -idx -nosound -noskip -ovc lavc -lavcopts
FAST       = vcodec=mjpeg
SLOW       = vcodec=ljpeg
STAMP      = echo done >
RM         = rm -rf

NPROC      = `nproc`

help:
	@echo "make all PHOTOS=<path> [FPS=<default 15> MODE=<fast/slow default fast> DEFLICKER=<yes/no default no>]"

ifeq ($(DEFLICKER), yes)
WORKING = $(DEFLICKERD)
WORKCHG = def.chg
else
WORKING = $(RESIZED)
WORKCHG = res.chg
endif

dir.chg:
	@echo "Making dirs"
	@if [ ! -d $(SRC) ]; then mkdir $(SRC); $(STAMP)dir.chg; fi
	@if [ ! -d $(RESIZED) ]; then mkdir $(RESIZED); $(STAMP)dir.chg; fi


cp.chg: dir.chg
	@echo "Copying files"
	@$(CP) $(PHOTOS)/*.JPG $(SRC)
	@$(STAMP)cp.chg

$(FILES): cp.chg
	@echo "Creating filelists"
	@$(LS) $(SRC) | $(CUT) > $(FILES)

res.chg: resize

resize: $(FILES)
	@echo "Resizing"
	@parallel -j $(NPROC) --eta 'mogrify -path $(RESIZED) -resize 1920x1080! -rotate "-90<" {}' ::: $(SRC)/*.JPG
	@$(STAMP)res.chg

def.chg: deflicker

deflicker: res.chg
	@echo "Deflickering"
	./timelapse-deflicker.pl -i $(RESIZED)/ -o $(DEFLICKERD)/
	@$(STAMP)def.chg

.INTERMEDIATE: deflicker resize

fast: $(WORKCHG)
	@echo "Fast convert"
	@cd $(WORKING); \
	$(MENCODEC) $(FAST) -o $(OUTPUT) -mf fps=$(FPS) 'mf://@$(FILES)'

slow: $(WORKCHG)
	@echp "Slow convert"
	@cd $(WORKING); \
	$(MENCODEC) $(SLOW) -o $(OUTPUT) -mf fps=$(FPS) 'mf://@$(FILES)'

ifeq ($(MODE),slow)
$(OUTPUT): slow
else
$(OUTPUT): fast
endif

final: $(OUTPUT)
	@echo "Making final mkv file"
	@avconv -i output.avi -c:v libx264 -preset slow -crf $(FPS) output-final.mkv

clean:
	@echo "Removing all files"
	@$(RM) *.chg
	@$(RM) $(FILES)
	@$(RM) $(SRC) $(RESIZED)
	@$(RM) *.avi
	@$(RM) *.mkv

all: final
