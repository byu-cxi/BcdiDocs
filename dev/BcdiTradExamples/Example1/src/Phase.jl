using BcdiTrad
using Plots
using FFTW

function saveAn(state, a)
    p1 = heatmap(fftshift(Array(abs.(state.realSpace)))[50,:,:])
    p2 = heatmap(fftshift(Array(angle.(state.realSpace)))[50,:,:])
    frame(a, plot(p1,p2,layout=2,size=(600,200)))
end

function phase()
    intensities = round.(Int64, reshape(parse.(Float64, split(readlines("../data/intensities.txt")[1], ",")), 100, 100, 100))

    state = BcdiTrad.State(intensities, trues(size(intensities)))
    er = BcdiTrad.ER()
    hio = BcdiTrad.HIO(0.9)
    shrink = BcdiTrad.Shrink(0.1, 1.0, state)
    center = BcdiTrad.Center(state)

    a = Animation()
    # We could run the commands this way, but we want to plot in the middle
    # center * er^500 * (center * er^20 * (shrink * hio)^80)^20 * state
    for i in 1:1600
        hio * state
        saveAn(state, a)
        shrink * state
    end
    for i in 1:100
        er * state
        saveAn(state, a)
    end
    center * state
    saveAn(state, a)

    mov(a, "../results/recon.webm", fps=250)
end

phase()
