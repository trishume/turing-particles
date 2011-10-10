type vector2D : record
    x : int
    y : int
   end record

type particle : record
    pos : vector2D
    vel : vector2D
    energy : int    
   end record
   
class ParticleSystem
    import vector2D,particle
    
    const maxParticles := 1000 % maximum number of particles
    var numParticles := 0 % number of particles on screen
    var p : array 1..maxParticles of particles % array of particles
    
    proc update
	for i : 1..numParticles
	    
	    % move it
	    p(i).pos.x += p(i).vel.x
	    p(i).pos.x += p(i).vel.x
	    
	    p(i).energy -= 1 %decrease energy
	end for
    end update
    
    proc draw
	for i : 1..numParticles
	    Draw.FillOval(p(i).x,p(i).y,5,5,blue)
	end for
    end
end ParticleSystem


