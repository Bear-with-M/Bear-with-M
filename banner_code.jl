using Plots
using Distributions
gr()

NAME = "M    A    R    C    I    N       B    E    A    R"
FADE_SPEED = Normal(50, 5)
PACE1 = Normal(0.02, 0.01)
PACE2 = Normal(0.05, 0.01)

mutable struct Star
    frame::Int64
    x::Float64
    y::Float64
    x₀::Float64
    y₀::Float64
    born::Int64
    fade_speed::Float64
    pace::Float64
end


fade(★::Star) = 1 - (★.frame - ★.born) / ★.fade_speed

function Plots.scatter!(stars::Array{Star,1}; markersize::Int64=3)
    for ★ in stars
        scatter!([★.x], [★.y],
                 color=:white,
                 markeralpha=fade(★),
                 label=false,
                 markerstrokewidth=1,
                 markersize=markersize)
    end
end


function trail!(stars::Array{Star,1}; size::Float64=1, dots::Int64=50)
    for ★ in stars
        α = LinRange(fade(★), 0, dots)
        scatter!(LinRange(★.x, ★.x₀, 50),
                 LinRange(★.y, ★.y₀, 50),
                 color=:white,
                 markersize=size,
                 alpha=α,
                 label=false)
    end
end


function shooting_stars(filename::String;
                        frames::Int64=100,
                        fps::Int64=24,
                        angle::Float64=0.02,
                        size::Tuple{Int64,Int64}=(900, 300),
                        small_stars_frequency::Int64=7,
                        medium_stars_frequency::Int64=17,
                        big_stars_frequency::Int64=31)

    a, b = rand(2)
    c, d = rand(2)
    small_stars = [Star(1, a, b, a, b, 1, 50., 0.02)]
    medium_stars = [Star(1, c, d, c, d, 1, 50., 0.05)]
    big_stars = [Star(1, 1, 1, 1, 1, 1, 50., 0.05)]
    x0, y0 = rand(70), rand(70)
    x02, y02 = rand(20), rand(20)
    x03, y03 = rand(10), rand(10)
    title = ((0.5, 0.3, text(NAME, "Avantgarde Book", 15, :white)))

    anim = @animate for i ∈ 1:frames

        scatter(x0, y0,
                color=:white,
                size=size,
                label=false,
                xlims = (0, 1),
                ylims = (0, 1),
                foreground_color=:black,
                background_color=:black,
                markersize=1,
                framestyle = :none)                                  # background stars

        scatter!(x02, y02, markersize=2, color=:white, label=false)  # background stars
        scatter!(x03, y03, markersize=3, color=:white, label=false)  # background stars
        annotate!(title)

        if i % small_stars_frequency == 0
            𝒳, 𝒴 = rand(2)
            append!(small_stars, [Star(i, 𝒳, 𝒴, 𝒳, 𝒴, i, rand(FADE_SPEED), rand(PACE1))])

        elseif i % medium_stars_frequency == 0
            𝒳, 𝒴 = rand(2)
            append!(medium_stars, [Star(i, 𝒳, 𝒴, 𝒳, 𝒴, i, rand(FADE_SPEED), rand(PACE2))])

        elseif i % big_stars_frequency == 0
            𝒳, 𝒴 = rand(2)
            append!(big_stars, [Star(i, 𝒳, 𝒴, 𝒳, 𝒴, i, rand(FADE_SPEED), rand(PACE2))])
        end

        scatter!(small_stars, markersize=1)
        trail!(small_stars, size=1.)

        scatter!(medium_stars, markersize=2)
        trail!(medium_stars, size=2.)

        scatter!(big_stars, markersize=3)
        trail!(big_stars, size=4.)

        for ★ in vcat(small_stars, medium_stars, big_stars)
            ★.x = ★.x - angle
            ★.y = ★.y - angle
            ★.frame = i
        end

        small_stars  = filter(★-> fade(★) > 0, small_stars)
        medium_stars = filter(★-> fade(★) > 0, medium_stars)
        big_stars    = filter(★-> fade(★) > 0, big_stars)
    end

    gif(anim, "$filename.gif", fps = fps)
end

shooting_stars("nickname"; frames=240, fps=24)
