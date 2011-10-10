View.Set ("offscreenonly")

type vector2D :
    record
	x : real
	y : real
    end record

fcn RandVector (min : real, max : real) : vector2D
    var v : vector2D

    v.x := (Rand.Real () * (max - min)) + min     % get random real number between ends
    v.y := (Rand.Real () * (max - min)) + min     % get random real number between ends

    result v
end RandVector

class Particle
    import vector2D, RandVector
    export Construct, Update, Render, SetNext, next, energy

    var pos : vector2D
    var vel : vector2D
    var energy : int

    var next : ^Particle

    deferred proc Construct (x : int, y : int)
    deferred proc Update (dt : int)
    deferred proc Render

    body proc Construct (x : int, y : int)
	pos.x := x
	pos.y := y

	vel := RandVector (-0.2, 0.2) % change numbers to alter how fast particles are

	energy := Rand.Int (200, 800) % change numbers to alter how fast particles die
    end Construct


    body proc Update (dt : int)
	% move it
	pos.x += vel.x * dt
	pos.y += vel.y * dt

	% POSIBILITIES! - drag:
	% might want to bump up the starting speed if using this
	/*
	 var drag := 0.0003
	 vel.x *= 1 - drag*dt
	 vel.y *= 1 - drag*dt
	 */

	% POSIBILITIES! - gravity:
	/*
	 var grav := 0.0009
	 vel.y -= grav*dt
	 */

	energy -= 1 * dt      %decrease energy
    end Update

    body proc Render
	% POSIBILITIES! - size:
	%var size := 2 %constant size
	var size := energy div 100          % size depends on energy

	Draw.FillOval (round (pos.x), round (pos.y), size, size, brightblue)
    end Render
    
    proc SetNext(n : ^Particle)
	next := n
    end SetNext
end Particle

class ParticleSystem
    import vector2D, Particle
    export Update, DrawParticles, AddParticle, Sweep

    var first : ^Particle := nil
    var last : ^Particle := nil

    proc Update (dt : int)
	var cur := first
	loop
	    exit when cur = nil

	    cur -> Update (dt)

	    cur := cur -> next %move to next one
	end loop
    end Update

    proc DrawParticles
	var cur := first
	loop
	    exit when cur = nil

	    if cur -> energy > 0 then
		cur -> Render
	    end if

	    cur := cur -> next %move to next one
	end loop
    end DrawParticles

    proc Sweep
	var cur := first
	loop
	    exit when cur = nil

	    if cur -> next not= nil and cur -> next -> energy <= 0 then
		var dead := cur -> next % save location

		cur -> SetNext(dead -> next) % fill gap

		if dead = last then % was it the last one
		    last := cur
		end if

		free dead
	    end if

	    cur := cur -> next %move to next one
	end loop
    end Sweep

    proc AddParticle (x : int, y : int)
	var cur : ^Particle

	if last = nil then % no particles
	    new first % allocate first
	    last := first
	    cur := first
	else % add to end
	    new cur % allocate a new particle

	    % tack it on
	    last -> SetNext(cur)
	    last := cur
	end if

	cur -> SetNext(nil)

	cur -> Construct (x, y)
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
    exit when chars ('q')
end loop



