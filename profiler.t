var profWin := Window.Open ("position:top;center,offscreenonly,graphics:200;200")
Window.Select(defWinID)
var profTime := 0
var lastTick := 0
var profSum := 0

proc ProfTick
    Window.Select(profWin)
    
    var delta := Time.Elapsed - lastTick
    put "total: ",delta,"ms"
    
    put "profiled: ",profSum/delta
    
    View.Update
    cls
    Window.Select(defWinID)
    
    lastTick := Time.Elapsed
    profSum := 0
end ProfTick

proc ProfBegin
    profTime := Time.Elapsed
end ProfBegin

proc ProfEnd(name : string)
    var delta := Time.Elapsed - profTime
    profSum += delta
    
    Window.Select(profWin)
    put name,": ",delta,"ms"
    Window.Select(defWinID)
end ProfEnd

