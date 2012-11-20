View.Set ("offscreenonly")

% a position/direction
% it has both direction, and MAGNITUDE! (despicable me reference)
type vector2D :
    record
        x : real
        y : real
    end record

% get a random position/direction with values between min and max
fcn RandVector (min : real, max : real) : vector2D
    var v : vector2D

    v.x := (Rand.Real () * (max - min)) + min     % get random real number between ends
    v.y := (Rand.Real () * (max - min)) + min     % get random real number between ends

    result v
end RandVector

% ====== ABSTRACT STUFF =======
% the particle class doesn't do anything by itself.
% it just embodies the essence of particleness.

class Particle
    import vector2D, RandVector
    export Construct, Update, Render, SetNext, next, energy

    var energy : int

    var next : ^Particle

    deferred proc Construct (x : int, y : int)
    deferred proc Update (dt : int)
    deferred proc Render


    proc SetNext (n : ^Particle)
        next := n
    end SetNext
end Particle

% ====== BASIC PARTICLE =======
% has velocity and position and draws as a circle

class *BasicParticle
    inherit Particle

    var pos : vector2D
    var vel : vector2D

    body proc Construct (x : int, y : int)
        pos.x := x
        pos.y := y

        % go pinging off in a random direction
        vel := RandVector (-0.2, 0.2) % CHANGE numbers to alter how fast particles are

        % how long it will last
        energy := Rand.Int (200, 800) % CHANGE numbers to alter how fast particles die
    end Construct

    deferred proc Extras (dt : int)
    body proc Extras (dt : int)

    end Extras

    body proc Update (dt : int)
        % move it
        pos.x += vel.x * dt
        pos.y += vel.y * dt

        % Use all the extra effects
        Extras (dt)

        energy -= 1 * dt      %decrease energy
    end Update

    body proc Render
        var size := 2 %constant size

        Draw.FillOval (round (pos.x), round (pos.y), size, size, brightblue)
    end Render
end BasicParticle


% ====== EXAMPLES =======
% some examples of creating your own particle types

class *SizeParticle
    inherit BasicParticle

    % if you create another class like this
    % remember to add it to the ParticleSystem imports

    body proc Render
        var size := energy div 100          % size depends on energy

        Draw.FillOval (round (pos.x), round (pos.y), size, size, brightblue)
    end Render
end SizeParticle

% This particle acts like water.
class *GravityParticle
    inherit SizeParticle

    % if you create another class like this
    % remember to add it to the ParticleSystem imports

    body proc Extras (dt : int)
        % CHANGE this
        var grav := 0.0009
        vel.y -= grav * dt % add to down speed (-y is down, remember math class?)
    end Extras
end GravityParticle

class *FireParticle
    inherit BasicParticle

    % if you create another class like this
    % remember to add it to the ParticleSystem imports
    
    body proc Render
        var size := energy div 100          % size depends on energy

        Draw.FillOval (round (pos.x), round (pos.y), size, size, brightred)
    end Render

    body proc Extras (dt : int)
        % CHANGE this
        var grav := 0.001
        vel.y += grav * dt % add to down speed (-y is down, remember math class?)
    end Extras
end FireParticle

class *DragParticle
    inherit BasicParticle

    % if you create another class like this
    % remember to add it to the ParticleSystem imports

    body proc Extras (dt : int)
        % CHANGE These numbers to add more drag
        var drag := 0.0003

        % slow down by multiplying by 1 - drag*dt
        % EX. 1 - 0.0003 * 1 = 0.9997
        % so speed gets smaller slowly
        vel.x *= 1 - drag * dt
        vel.y *= 1 - drag * dt
    end Extras
end DragParticle

class *WavyParticle
    inherit BasicParticle

    % if you create another class like this
    % remember to add it to the ParticleSystem imports

    body proc Render
        var size := round (cos (pos.y * 0.1) + sin (pos.x * 0.1) + 2)  % size depends function

        Draw.FillOval (round (pos.x), round (pos.y), size, size, brightblue)
    end Render
end WavyParticle

class *ColoredParticle
    inherit BasicParticle

    % if you create another class like this
    % remember to add it to the ParticleSystem imports

    body proc Render
        var size := energy div 150
        %var col := Rand.Int(1,200)
        var col := abs (round ((sin (energy div 50) * 20) + 40))

        Draw.FillOval (round (pos.x), round (pos.y), size, size, col)
    end Render
end ColoredParticle

% ====== THE MASTERMIND =======
% the system wrangles all 'dem particles

class ParticleSystem
    import vector2D, Particle
    export Update, DrawParticles, AddParticle, AddParticles, Sweep

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

                cur -> SetNext (dead -> next) % fill gap

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

        % CHANGE THIS, DO IT:
        % change particle type here
        % change to any of the particle classes
        % example:
        %new SizeParticle, cur
        %new WavyParticle, cur
        %new FireParticle, cur
        new ColoredParticle, cur % allocate a new particle
        % ===============================================

        if last = nil then % no particles
            first := cur
            last := first
        else
            % tack particle on
            last -> SetNext (cur)
            last := cur
        end if

        cur -> SetNext (nil)

        cur -> Construct (x, y)
    end AddParticle

    proc AddParticles (x : int, y : int, num : int)
        for i : 1 .. num
            AddParticle (x, y)
        end for
    end AddParticles
end ParticleSystem

% ====== BASIC USAGE =======
% create particles at mouse click

var ps : ^ParticleSystem
new ps

var lastFrame := Time.Elapsed
const sweepFreq := 50 % higher sweeps less often

loop
    var x, y, button : int
    Mouse.Where (x, y, button)
    if button > 0 then
        ps -> AddParticles (x, y, 2)
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



