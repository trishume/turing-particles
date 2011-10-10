type vector2D : record
    x : real
    y : real
   end record

type particle : record
    pos : vector2D
    vel : vector2D
    energy : int    
   end record
   
View.Set("offscreenonly")
   
class ParticleSystem
    import vector2D,particle
    export Update,DrawParticles,AddParticle
    
    const maxParticles := 1000 % maximum number of particles
    var numParticles := 0 % number of particles on screen
    var p : array 1..maxParticles of particle % array of particles
    
    proc Update
	for i : 1..numParticles
	    
	    % move it
	    p(i).pos.x += p(i).vel.x
	    p(i).pos.y += p(i).vel.y
	    
	    p(i).energy -= 1 %decrease energy
	end for
    end Update
    
    proc DrawParticles
	for i : 1..numParticles
	    if p(i).energy > 0 then
		Draw.FillOval(round(p(i).pos.x), round(p(i).pos.y), 2, 2, brightblue)
	    end if
	end for
    end DrawParticles
    
    fcn RandVector(min:int,max:int) : vector2D
	var v : vector2D
	
	v.x := (Rand.Real() * (max-min)) + min % get random real number between ends
	v.y := (Rand.Real() * (max-min)) + min % get random real number between ends
	
	result v
    end RandVector
    
    proc AddParticle(x:int,y:int)
	var n := numParticles + 1 % index of new particle
	
	if n > maxParticles then
	    n := n mod maxParticles
	end if
	
	
	p(n).pos.x := x
	p(n).pos.y := y
	
	p(n).vel :=  RandVector(-1,1) % random velocity
	
	p(n).energy := 100 % arbitrary
	
	numParticles += 1
    end AddParticle
end ParticleSystem

var ps : ^ParticleSystem
new ps

loop
    var x,y,button : int
    Mouse.Where(x,y,button)
    if button > 0 then
	ps->AddParticle(x,y)
    end if
    
    % comment out for full trails:
    cls
    
    ps->Update
    ps->DrawParticles
    View.Update
end loop



