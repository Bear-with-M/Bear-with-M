using Plots
using Distributions
using Random
gr()

NAME = "BEAR WITH M" |> collect |> s -> join(s, "   ")
FADE_SPEED_DIST = Normal(50, 5) 
PACE_DIST = LogNormal(0, 0.1)
TRAIL_LENGTH = 40:50:60


"""
    mutable struct Star

    A data structure to represent a star.

    - `x0` and `y0` are the initial positions of the star.
    - `x` and `y` are the current positions of the star.
    - `frame` is the current frame of the animation.
    - `born` is the frame when the star was born.
    - `fade_speed` is the speed at which the star fades.
    - `pace` is the speed at which the star moves.
    - `markersize` is the size of the star.
    - `trail_length` is the length of the trail of the star.
    """
mutable struct Star
    x0::Float64
    y0::Float64
    x::Float64
    y::Float64
    frame::Int64
    born::Int64
    fade_speed::Float64
    pace::Float64
    markersize::Float64
    trail_length::Int64
end


"""
    spawn_star(frame::Int64, size::Int64)

Create a new star at the given frame and size.

Returns a `Star` object with the given frame and size, and a random
position, fade speed, pace, and trail length.
"""
function spawn_star(frame::Int64, size::Int64)
    x0, y0 = rand(2)
    fade_speed = rand(FADE_SPEED_DIST)
    trail_length = sample(TRAIL_LENGTH)
    pace = rand(PACE_DIST)
    return Star(
        x0, y0, x0, y0,
        frame, frame,
        fade_speed, pace, size,
        trail_length
        )
end

"""
    fade(★::Star) -> Float64

Calculate the fade level of a star.

The fade level is determined by how long the star has been alive relative to its fade speed. 
A value of 1 indicates a newly born star, while a value of 0 indicates a fully faded star.
"""
fade(★::Star) = 1 - (★.frame - ★.born) / ★.fade_speed


"""
    scatter!(stars::Array{Star,1})

Plot all the stars in the given array.

The `markeralpha` argument is set to the fade level of the star, which
is calculated by the `fade` function.
"""
function Plots.scatter!(stars::Array{Star,1})
    for ★ in stars
        scatter!(
            [★.x], [★.y],
            color=:white,
            markeralpha=fade(★),
            label=false,
            markerstrokewidth=1,
            markersize=★.markersize
        )
    end
end


"""
    trail!(stars::Array{Star,1})

    Plot the trail of stars in the given array.

    - `stars`: An array of `Star` objects.
"""
function trail!(stars::Array{Star,1})
    for ★ in stars
        alpha = LinRange(fade(★), 0, ★.trail_length)
        scatter!(
            LinRange(★.x, ★.x0, ★.trail_length),
            LinRange(★.y, ★.y0, ★.trail_length),
            color=:white,
            markersize=★.markersize,
            alpha=alpha,
            label=false
        )
    end
end


"""
    shooting_stars(filename::String;
                   frames::Int64=100,
                   fps::Int64=24,
                   angle::Float64=0.02,
                   small_bkg_stars::Int64=70,
                   medium_bkg_stars::Int64=20,
                   big_bkg_stars::Int64=10,
                   size::Tuple{Int64,Int64}=(900, 300),
                   frequencies::Dict=Dict(1=>7, 2=>17, 3=>31),
                   seed::Union{Nothing,Int64}=nothing)

Generate an animated GIF of shooting stars.

- `filename`: The output filename for the GIF.
- `frames`: Number of frames in the animation.
- `fps`: Frames per second of the animation.
- `angle`: Angle of movement for the stars.
- `small_bkg_stars`: Number of small background stars.
- `medium_bkg_stars`: Number of medium background stars.
- `big_bkg_stars`: Number of big background stars.
- `size`: Size of the plot.
- `frequencies`: A dictionary mapping star types to their spawn frequencies.
- `seed`: An optional seed for the random number generator. If `nothing`, the
  radnom seed is used. If an integer, the seed is set to that value before
  generating the animation.
"""
function shooting_stars(filename::String;
                        frames::Int64=100,
                        fps::Int64=24,
                        angle::Float64=0.02,
                        small_bkg_stars::Int64=70,
                        medium_bkg_stars::Int64=20,
                        big_bkg_stars::Int64=10,
                        size::Tuple{Int64,Int64}=(900, 300),
                        frequencies::Dict=Dict(1=>7, 2=>17, 3=>31),
                        seed::Union{Nothing,Int64}=nothing)

    Random.seed!(seed)
    frequencies = Dict(values(frequencies) .=> keys(frequencies))
    stars = [spawn_star(1, s) for s ∈ 1:3]
    x01, y01 = rand(small_bkg_stars),  rand(small_bkg_stars)
    x02, y02 = rand(medium_bkg_stars), rand(medium_bkg_stars)
    x03, y03 = rand(big_bkg_stars),    rand(big_bkg_stars)
    title = ((0.5, 0.3, text(NAME, "Avantgarde Book", 15, :white)))
    anim = @animate for i ∈ 1:frames

        plot(
            size=size,
            label=false, 
            xlims=(0, 1), 
            ylims=(0, 1),
            foreground_color=:black,
            background_color=:black,
            markersize=1,
            framestyle=:none
        )

        scatter!(x01, y01, markersize=1, color=:white, label=false)  # background stars
        scatter!(x02, y02, markersize=2, color=:white, label=false)  # background stars
        scatter!(x03, y03, markersize=3, color=:white, label=false)  # background stars
        annotate!(title)

        for key in keys(frequencies)
            if i % key == 0
                push!(stars, spawn_star(i, frequencies[key]))
            end
        end

        scatter!(stars); trail!(stars)

        for ★ in stars
            ★.x = ★.x - ★.pace * angle
            ★.y = ★.y - ★.pace * angle
            ★.frame = i
        end
        stars  = filter(★ -> fade(★) > 0, stars)
    end
    gif(anim, "$filename.gif", fps = fps)
end

shooting_stars("banner1"; frames=240, fps=24, seed=6)
