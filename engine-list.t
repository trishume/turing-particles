type vector2D :
    record
	x : real
	y : real
    end record

type particle :
    record
	pos : vector2D
	vel : vector2D
	energy : int

	next : ^particle % OMG! A linked list!
    end record

View.Set ("offscreenonly")

class ParticleSystem
    import vector2D, particle
    export Update, DrawParticles, AddParticle, Sweep

    var first : ^particle := nil
    var last : ^particle := nil

    proc Update (dt : int)
	var cur := first
	loop
	    exit when cur = nil

	    % move it
	    cur -> pos.x += cur -> vel.x * dt
	    cur -> pos.y += cur -> vel.y * dt
	    
	    % POSIBILITIES! - drag:
	    % might want to bump up the starting speed if using this
	    /*
	    var drag := 0.0003
	    cur -> vel.x *= 1 - drag*dt
	    cur -> vel.y *= 1 - drag*dt
	    */

	    cur -> energy -= 1 * dt %decrease energy

	    cur := cur -> next %move to next one
	end loop
    end Update

    proc DrawParticles
	var cur := first
	loop
	    exit when cur = nil

	    if cur -> energy > 0 then
		% POSIBILITIES! - size:
		%var size := 2 %constant size
		var size := cur->energy div 100 % size depends on energy
	    
		Draw.FillOval (round (cur -> pos.x), round (cur -> pos.y), size, size, brightblue)
	    end if

	    cur := cur -> next %move to next one
	end loop
    end DrawParticles

    fcn RandVector (min : real, max : real) : vector2D
	var v : vector2D

	v.x := (Rand.Real () * (max - min)) + min % get random real number between ends
	v.y := (Rand.Real () * (max - min)) + min % get random real number between ends

	result v
    end RandVector

    proc Sweep
	var cur := first
	loop
	    exit when cur = nil

	    if cur -> next not= nil and cur -> next -> energy <= 0 then
		var dead := cur -> next % save location

		cur -> next := dead -> next % fill gap

		if dead = last then % was it the last one
		    last := cur
		end if

		free dead
	    end if

	    cur := cur -> next %move to next one
	end loop
    end Sweep

    proc AddParticle (x : int, y : int)
	var cur : ^particle

	if last = nil then % no particles
	    new first % allocate first
	    last := first
	    cur := first
	else % add to end
	    new cur % allocate a new particle

	    % tack it on
	    last -> next := cur
	    last := cur
	end if

	cur -> next := nil

	cur -> pos.x := x
	cur -> pos.y := y

	cur -> vel := RandVector (-0.2, 0.2) % change numbers to alter how fast particles are

	cur -> energy := Rand.Int (100, 700) % change numbers to alter how fast particles die
    end AddParticle
end ParticleSystem

var ps : ^ParticleSystem
new ps

var lastFrame := Time.Elapsed
const sweepFreq := 50 % higher sweeps less often

loop
    var x, y, button : int
    Mouse.Where (x, y, button)
    if button > 0 then
	ps -> AddParticle (x, y)
    end if

    % comment out for full trails:
    cls

    if Rand.Int (0, sweepFreq) = 1 then
	ps -> Sweep
    end if

    ps -> Update (Time.Elapsed - lastFrame)
    lastFrame := Time.Elapsed

    ps -> DrawParticles
    View.Update

    % q key to quit
    var chars : array char of boolean
    Input.KeyDown (chars)
    exit when chars('q')
end loop



