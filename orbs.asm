	
.var SPRITE_BASE = $b0
.var bank =$8000
.var SPRITE_ADDR = $2c00
.var music = LoadSid("Room_2.sid")


BasicUpstart2(main)
	* = * "TABLE"
table_lo:
	.fill 18,<(bank+$3100+floor(i/3)*64+mod(i,3))
table_hi:
	.fill 18,>(bank+$3100+floor(i/3)*64+mod(i,3))
frame:
	.word 0
	
waittext:
	.byte 0
	
jumpNextLevel:
	.byte 0
	
rew_text:
	.text "ABCDEFGHILMNOPQRST"
	.byte $0
	
curchar:
	.byte $0

rotationa:
       .byte 0
rotationb:
       .byte 63	
joy:
		.byte 0
DUMMY:
		.byte 0

COLLISON:
		.byte 0		
rewind:
	.byte 0
	
sprite_idx:
	.byte 0
	
bit_mask:
	.byte 1,2,4,8,16,32,64,128
mask:
	.byte 0


cur_data:
	.word data
next_data:
	.word 0
	
tot_data:
	.byte 0
numblock:
	.byte 0

blockid:
	.byte 0
blockx:
	.byte 0
blocky:
	.byte 0
	
vert:
	.byte 0

fade_table:
	.byte $0,$b,$c,$f,$01,$0F,$0c,$b,$0
	

update_player: {
	lda joy            
	and #$4
	beq check_joy_right
	dec rotationa
	dec rotationb
	
check_joy_right:
	lda joy            
	and #$8
	beq none
	inc rotationa
	inc rotationb
none:
	rts
}

clearscreen:{
	ldy #$0
	
	ldx #0
rep:
	lda #0
	sta bank+$400,y
	sta bank+$500,y
	sta bank+$600,y
	sta bank+$700,y
	//sta bank+$800,y
/*	lda #14
	sta $d800,y
	sta $d900,y
	sta $da00,y
	sta $db00,y*/
	iny
	bne rep
	rts
}
getjoy: {
	lda     #$FF
	sta     $DC00
	lda     $DC00
	eor     #$FF
	sta     joy
	rts
}

vblank: {
	lda $d011
	bmi vblank
L2: 
	lda $d011
	bpl L2
	rts
}

* = * "CODE"	

prepare_text:{
	

	
	ldy #0
	lda #$0	
	sty 53277
	sty 53271

nn0:
	sta bank+$3100,y
	sta bank+$3200,y
	iny
	bne nn0

	ldx #0
	stx curchar
	

	lda #<rew_text
	sta $4
	lda #>rew_text
	sta $5
	
nextchar:	
	
	ldy curchar
	
	lda table_lo,y
	sta $2
	lda table_hi,y
	sta $3
	
	lda ($4),y
	beq fine
	cmp #32
	beq cas
	
	asl
	asl
	asl
	tax
	 
	ldy #0
n1:
	lda $c000,x
	sta ($2),y
	inx
	
	iny
	iny
	iny
	
	cpy #23
	bcc n1
	

	//inc16($2)
cas:
	inc curchar
	
	jmp nextchar
fine:


	lda #$C4
	sta bank+$07fA
	lda #$C5
	sta bank+$07fB
	lda #$C6
	sta bank+$07fC
	lda #$C7
	sta bank+$07fD
	lda #$C8
	sta bank+$07fE
	lda #$C9
	sta bank+$07ff
	
	lda #1
	sta $D029
	sta $D02A
	sta $D02B
	sta $D02C
	sta $D02D
	sta $D02E
	sta $D02F

	
	lda #110+0*24
	sta $d004
	
	lda #110+1*24
	sta $d006

	lda #110+2*24
	sta $d008
	
	lda #110+3*24
	sta $d00A

	lda #110+4*24
	sta $d00c
	
	lda #110+5*24
	sta $d00e
	
	lda #$ff
	sta $d015	
	

	lda #$3
	sta $D01C 
	lda #0
	sta waittext
	
	rts
}
showtitle:{
	
	lda #11
	sta $d022
	lda #12
	sta $d023

	lda #200
	ora #16
	sta $d016
  
  
	ldy #0
	
L01:
	lda titlecharset,y
	sta bank+$2000,y
	lda titlecharset+$100,y
	sta bank+$2000+$100,y
	lda titlecharset+$200,y
	sta bank+$2000+$200,y
	lda titlecharset+$300,y
	sta bank+$2000+$300,y
	lda titlecharset+$400,y
	sta bank+$2000+$400,y
	lda titlecharset+$500,y
	sta bank+$2000+$500,y
	
	iny
	bne L01
	
	
L02:
	//lda titlescreen,y
	lda ($02),y
	sta bank+$400,y
	tax
	lda attrscreen,x
	sta $d800,y
	
	
	
	//lda titlescreen+$100,y
	lda ($04),y
	sta bank+$500,y
	tax
	lda attrscreen,x
	sta $d900,y
	
	
	
	lda ($06),y
	//lda titlescreen+$200,y
	sta bank+$600,y
	tax
	lda attrscreen,x
	sta $da00,y
	
	
	iny
	bne L02

L03:
	lda ($08),y
	//lda titlescreen+$200,y
	sta bank+$700,y
	tax
	lda attrscreen,x
	sta $db00,y
	
	iny
	cpy #200
	bcc L03
	rts
}

process_frame: {

	inc16(scroll_id)
	
	lda rewind
	beq lo1
	jmp gorewind
lo1:
	jsr getjoy	
	jsr update_player
	jsr draw_player
	lda waittext
	cmp #130
	bcs normalgame
	inc waittext
	
	lda waittext
	lsr
	lsr	
	pha
	
	//lsr
	
	clc
	adc #90
	sta $d005
	sta $d007
	sta $d009
	sta $d00B
	sta $d00D
	sta $d00F
	
	pla
	lsr
	lsr
	tay
	
	lda fade_table,y
	
	sta $D029
	sta $D02A
	sta $D02B
	sta $D02C
	sta $D02D
	sta $D02E
	sta $D02F

	jmp leave
normalgame:
	jsr update_level
	lda jumpNextLevel
	beq noLevelCompleted	
	jsr load_level_pointers
	lda restart 
	beq cont
	rts
cont:
	jsr load_next_level
	jmp process_frame
noLevelCompleted:	
	jsr update_ent
	
	lda $D01E
	sta COLLISON
	and #1
	bne coll
	lda COLLISON
	and #2
	bne coll

	inc16(time_id)
	
	/*inc time_id
	bne leave
	inc time_id+1
	*/
	rts
	
gorewind:
	jsr update_level
	jsr update_ent
	
	lda time_id
	sec
	sbc #6
	sta time_id
	
	lda time_id+1
	sbc #0
	sta time_id+1
	

	lda time_id+1
	bpl leave
	lda #0
	sta time_id
	sta time_id+1
	sta rewind
	/*ldy # 0
	lda #1
nn:
	sta $0500,y
	iny
	bne nn
	*/
leave:	
	rts
	
coll:
	lda #1
	sta rewind
	
	lda #<rew_text
	sta $02
	lda #>rew_text
	sta $03
	
	rts
}

main: {	
	lda #00
	sta $d015
	.for (var i=0;i<$18;i++) 
	sta $D400+i
		
	sta restart
	sta level
    /*sta $3fff*/
	sta $d020
	sta $d021
	jsr clearscreen
	
	lda #SPRITE_BASE+2
	sta bank+$07f8
	sta bank+$07f9

	
	lda #$3
	sta $D01C 
		
	//jsr load_global_data
	
	lda $dd00
	and #%11111100
	ora #1           //          ;  Bank #1, $4000-$7FFF, 16384-32767.
	sta $dd00 
	
	lda $d018
	and #%11110000
	ora #%00001000
	sta $d018
	sei
	lda #$33
	sta $1
	
	ldy #0
ncc:
.for (var j=0;j<6;j++) {
	lda sprites+($100*j),y
	sta bank+SPRITE_ADDR+($100*j),y
	
}	

	lda     $D000,y	
	sta     $c000,y

	iny
	bne ncc

	lda #$37
	sta $1

	cli
	
	lda #<titlescreen
	sta $02
	lda #>titlescreen
	sta $03

	lda #<titlescreen+$100
	sta $04
	lda #>titlescreen+$100
	sta $05

	lda #<titlescreen+$200
	sta $06
	lda #>titlescreen+$200
	sta $07

	lda #<titlescreen+$300
	sta $08
	lda #>titlescreen+$300
	sta $09

	jsr showtitle
	
L03:
	jsr getjoy
	lda joy            
	and #$10
	beq L03

	
	jsr clearscreen
	
	lda #<background
	sta $02
	lda #>background
	sta $03

	lda #<background+$100
	sta $04
	lda #>background+$100
	sta $05

	lda #<background+$200
	sta $06
	lda #>background+$200
	sta $07

	lda #<background+$300
	sta $08
	lda #>background+$300
	sta $09
	jsr showtitle
	
	lda #SPRITE_BASE+2
	sta bank+$07f8
	sta bank+$07f9
	
	lda #14
	sta $D025
	lda #6	
	sta $D026	

	
	//jsr prepare_screen
	jsr load_level_pointers
	jsr load_next_level
	
	
	lda #0
	jsr music.init

	
END:
		
	jsr vblank
	//jsr drawstarfield
	jsr process_frame
	jsr music.play
	lda restart
	beq END
	jmp main
	rts
}
	




draw_player: {

	lda #1
	sta $D027
	sta $D028
	
	lda rotationa
	asl
	tax
	lda postabley,x
	clc
	adc #50
	sta $d001


	lda postablex,x
	sta $d000
	
	lda rotationb
	asl
	tax
	lda postabley,x
	clc
	adc #50
	sta $d003
	
	lda postablex,x
	sta $d002
	
	rts	
}
	
update_level:{

	lda #0
	sta ent_size
	sta jumpNextLevel
	
	ldy #$ff
	

next:
	iny
	cpy tot_data
	bcc continue
	rts
continue:

add_sprite:
	
	lda time_id
	sec
	sbc spawn_at_lo,y
	sta	frame
	lda time_id+1
	sbc spawn_at_hi,y
	sta frame+1
	
	lda frame+1
	bne next
	lda frame    //// se sta fuori dallo schermo viene scartato
	cmp #252
	bcs next
	
	
//jsr ent_get_free   // ritorna in x uno slot libero
	lda spawn_flag,y
	cmp #$ff
	beq endLevelOk
	
/// verifica se è finito il livello	
	lda ent_size
	tax


	lda spawn_flag,y
	sta ent_flag,x

	
	lda spawn_x_hi,y
	sta ent_x_hi,x
	
	lda spawn_x_lo,y
	sta ent_x_lo,x

	lda spawn_y_lo,y
	sta ent_y_lo,x
	
	lda spawn_flag,y
	and #$10                    /// static object
	bne cca1
	lda spawn_flag,y
	and #$20                    /// indica la direzione da sinistra verso destra
	beq move_top_down
	
	////// custom movement
	lda #170
	sta $a0
	lda frame
	cmp #170
	bcs klo
	sta $a0
klo:		
	lda spawn_x_lo,y
	clc
	//adc frame
	adc $A0
	sta ent_x_lo,x
	
	lda spawn_x_hi,y
	adc #0
	sta ent_x_hi,x
	
	jmp  cca1
move_top_down:
	lda spawn_y_lo,y
	clc
	adc frame
	sta ent_y_lo,x
cca1:

	lda #1
	sta ent_active,x
	
	
	lda spawn_frame,y
	sta ent_frame,x
	lda spawn_frame_end,y
	beq ok
	
	lda frame
	lsr
	lsr
	and spawn_frame_end,y
	clc
	adc spawn_frame,y
	
	sta ent_frame,x
ok:	
	/*	
	sta ent_frame,x
	sta ent_cur_frame,x

	lda spawn_frame_end,y
	sta ent_frame_end,x
	*/
	
	
	inc ent_size
	jmp next

	rts
endLevelOk:
	
	lda #1
	sta jumpNextLevel
	rts
}
	

update_ent:
{
	ldx #$0
	stx 53264
	stx 53277
	stx 53271
	

	
	/*lda #$3
	sta $D01C 
*/
	
	ldy #2
	sty sprite_idx
	
	lda #$3
	sta mask
	
	//lda #0
	//sta $d01c
	
continue:
	cpx ent_size
	bcc cc1
	jmp leave
cc1:
	ldy sprite_idx
	
	lda bit_mask,y 
	ora mask
	sta mask
	
	lda ent_x_hi,x
	beq no_extra_coord
	lda bit_mask,y 
	ora 53264
	sta 53264
no_extra_coord:

	lda ent_flag,x
	and #$80
	beq no_double_x
	lda 53277
	ora bit_mask,y	
	sta 53277
no_double_x:	
	lda ent_flag,x
	and #$01
	beq no_double_y
	lda  53271
	ora bit_mask,y	
	sta  53271
no_double_y:	
	lda ent_flag,x
	and #$40
	beq no_mc
	lda  $D01C 
	ora  bit_mask,y	
	sta  $D01C 
	
no_mc:
	//lda ent_frame,x	
	lda ent_frame,x
	sta bank+$07f8,y
	//sta $87F8,y
no_reset:	
	lda #3
	sta $D027,y
	tya
	asl
	tay
	
	lda ent_x_lo,x
	sta $d000,y
	
	

	//inc ent_y_lo,x
	//inc ent_y_lo,x

	/*lda ent_y_lo,x
	cmp #250
	bcc no_remove
	lda #0
	sta ent_active,x	*/
	
no_remove:
	lda ent_y_lo,x
	sta $d001,y
	
	inc sprite_idx
next:
	inx	
	jmp continue

leave:
	lda mask
	//sta $0402
	sta $d015	

	
	rts
}

//*=* "ENTITIES"

charsize:
	.word 0
	
.macro inc16(ptr) {
	inc ptr
	bne noinc
	inc ptr+1
noinc:	
}
.macro add16(ptr,v) {
	lda ptr
	clc
	adc #v
	sta ptr
	
	lda ptr+1
	adc #v
	sta ptr+1
}


restart:
	.byte 0
numLevels:
	.byte 0
	
levelPtr:
	.word 0
level:
	.byte 0
load_level_pointers: {
	ldy level
	lda cur_data 
	sta $02
	lda cur_data+1
	sta $03

	lda level
	asl
	tay
	
	
	lda ($02),y     
	sta levelPtr
	
	iny
	lda ($02),y     
	sta levelPtr+1

	lda levelPtr
	cmp #$ff
	bne next_level
	
	lda levelPtr+1
	cmp #$ff
	bne next_level
	
	lda #1
	sta restart
	rts
next_level:
	
	inc level
	rts
}
load_next_level: {

/*
spawn_at_hi:
spawn_at_lo:
spawn_id:
spawn_x_hi:
spawn_x_lo:
spawn_y_lo:
spawn_frame:
*/	
	
	ldy #0
	sty jumpNextLevel
	sty time_id
	sty time_id+1
	
	lda levelPtr
	sta $02
	lda levelPtr+1
	sta $03
	
end_block:
	
	ldy #0
nna:
	lda ($02),y
	sta rew_text,y
	iny
	cpy #18
	bne nna
	
	lda $2
	clc
	adc #18
	sta $2
	
	lda $3
	adc #0	
	sta $3
	
	ldy #0
	lda ($02),y
	sta tot_data
	iny

	inc $02
	bne noinc
	inc $03
noinc:
	
	ldy #0
next:
	lda ($02),y  
	sta spawn_frame,x
	iny 
	
	lda ($02),y  
	sta spawn_frame_end,x
	iny 

	lda ($02),y  
	sta spawn_flag,x
	iny 

	lda ($02),y   // posx lo
	sta spawn_x_lo,x
	iny
	
	lda ($02),y   // posx hi
	sta spawn_x_hi,x
	iny
	
	lda ($02),y   // posy lo
	sta spawn_y_lo,x
	iny
	//iny       // skip pos y hi
	
	/*lda ($02),y   // spawn_id
	sta spawn_id,x
	iny
	iny         /// skip spand_id 
	*/
	lda ($02),y   // spawn_at_lo
	sta spawn_at_lo,x
	iny	
	
	lda ($02),y   // spawn_at_hi
	sta spawn_at_hi,x
	iny	
		
	inx
	cpx tot_data
	beq return
	
continue:
		
	//ldy #0	
	jmp next
return:
	lda #$ff 
	sta spawn_at_lo,x
	sta spawn_at_hi,x
	
	jsr prepare_text
	
	rts
		
}

*=* "GRAPHICS"
postabley:
	.import binary "datay.bin"
postablex: 
	.import binary "datax.bin"	
attrscreen:
	.import binary "raw_attr.bin"
*=* "LEVEL LUT"
data:	

*=music.location "Music"
        .fill music.size, music.getData(i)
		
*=* "GRAPHICS"
sprites:
	.import binary "duets-white-3.raw"

titlecharset:
	.import binary "raw_charset.bin"
titlescreen:
	.import binary "raw_map.bin"
background:
	.import binary "background.bin"


*=* "GAMELOGIC"
levels_data:

*=$c100 "VARIABLES" virtual

time_id:
	.word $0
	
scroll_id:
	.word $0
	
spawn_at_hi:
	.fill $ff, 0
spawn_at_lo:
	.fill $ff, 0
spawn_id:
	.fill $ff, 0
spawn_x_hi:
	.fill $ff, 0
spawn_x_lo:
	.fill $ff, 0
spawn_y_lo:
	.fill $ff, 0	
spawn_frame:
	.fill $ff, 0
spawn_frame_end:
	.fill $ff, 0

spawn_flag:
	.fill $ff, 0

ent_size:
	.byte 0
ent_active:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ent_x_lo:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ent_x_hi:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ent_y_lo:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ent_frame:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ent_frame_end:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ent_cur_frame:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ent_flag:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ent_delay:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	
	