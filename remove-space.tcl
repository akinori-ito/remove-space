frame .f
checkbutton .f.spc -text "Preserve spaces between lines" -variable spc
button .f.rmv -text "Join lines" -command remove_space
button .f.clr -text Clear -command "record_undo; .t delete 1.0 end"
button .f.undo -text Undo -command undo
label .f.undocount -textvariable undocount
pack .f.spc .f.rmv .f.clr .f.undo .f.undocount -side left

text .t
pack .f .t -side top

set undobuf {}
set undocount 0

proc record_undo {} {
  global undobuf undocount
  lappend undobuf  [.t get 1.0 end]
  set undocount [llength $undobuf]
}

# ff  11 64256
# fi  12
# ffi 14 64259
# fl  10 13

proc do_replace {txt spc} {
  set txt [regsub -all "^ *" $txt {}]
  set txt [regsub -all -- "-\n" $txt {}]
  set txt [regsub -all " *\n" $txt $spc]
  set txt [regsub -all [format %c 10] $txt fl]
  set txt [regsub -all [format %c 11] $txt ff]
  set txt [regsub -all [format %c 12] $txt fi]
  set txt [regsub -all [format %c 14] $txt ffi]
  set txt [regsub -all [format %c 64256] $txt ff]
  set txt [regsub -all [format %c 64259] $txt ffi]
  set txt [regsub -all [format %c 13] $txt fl]
  return $txt
}

proc remove_space {} {
  global spc
  set text [.t get 1.0 end]
  record_undo
  .t delete 1.0 end
  set lastspc ""
  if {$spc} {
    set lastspc " "
  } 
  .t insert end [do_replace $text $lastspc]
}

proc undo {} {
  global undobuf undocount
#  if {$undocount > 1} {
    .t delete 1.0 end
    .t insert end [lindex $undobuf end]
    set undobuf [lreplace $undobuf end end]
    set undocount [llength $undobuf]
#  }
}