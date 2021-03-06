export StateOverriddenEnv

"""
    StateOverriddenEnv(f, env)

Apply `f` to override `state(env)`.

!!! note
    If the meaning of state space is changed after apply `f`, one should
    manually redefine the `RLBase.state_space(env::YourSpecificEnv)`.
"""
struct StateOverriddenEnv{F,E<:AbstractEnv} <: AbstractEnvWrapper
    env::E
    f::F
end

StateOverriddenEnv(f) = env -> StateOverriddenEnv(f, env)

(env::StateOverriddenEnv)(args...; kwargs...) = env.env(args...; kwargs...)

for f in vcat(RLBase.ENV_API, RLBase.MULTI_AGENT_ENV_API)
    if f ∉ (:state,)
        @eval RLBase.$f(x::StateOverriddenEnv, args...; kwargs...) =
            $f(x.env, args...; kwargs...)
    end
end

RLBase.state(env::StateOverriddenEnv, args...; kwargs...) =
    env.f(state(env.env, args...; kwargs...))

RLBase.state(env::StateOverriddenEnv, ss::RLBase.AbstractStateStyle) =
    env.f(state(env.env, ss))

RLBase.state_space(env::StateOverriddenEnv, ss::RLBase.AbstractStateStyle) =
    state_space(env.env, ss)
