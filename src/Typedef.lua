---@meta

---@alias colortext table
---@alias color number 		Preferably Hex Color
---@alias percentage number from 0 to 1
---@alias severityLevel "debug" | "info" | "warn" | "error"
---@alias numeric number|vector|Mat4
---@alias consumer<T> fun(T): nil
---@alias predicate<T> fun(T): boolean
---@alias dynamic<T> fun(): T
---@alias uuid string
---@alias pivot vector

-- These are for clarity
---@alias queue<T> [T]
---@alias stack<T> [T]
---@alias dictionary<T> {[string]: T}
---@alias Set<T> {[T]: true}

---@alias monad<T, U> T|U|{__interior: T}