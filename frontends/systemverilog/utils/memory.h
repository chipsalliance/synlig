#ifndef SYSTEMVERILOG_PLUGIN_UTILS_MEMORY_H_
#define SYSTEMVERILOG_PLUGIN_UTILS_MEMORY_H_

#include <cassert>
#include <utility>

namespace systemverilog_plugin
{

// `std::default_delete` equivalent for any range of pointers, e.g. `std::vector<Object *>`.
template <class Range> struct default_delete_ptr_range {
    void operator()(Range &range) const
    {
        for (auto *ptr : range)
            delete ptr;
    }
};

// Functor that takes a reference and does nothing. Useful as no-op deleter.
struct noop_delete {
    template <class T> void operator()(T &) const {}
};

namespace utils_memory_internal
{

// Unique type for detecting invalid (missing) default_resource_deleter.
struct missing_type {
};

// Provider of default deleter functor for resource of type `R` used by `unique_resource`.
template <class R, class AlwaysVoid_ = void> struct default_resource_deleter {
    using type = missing_type;
};

// Type trait for detecting whether type `R` is any range of pointers.
template <class R, class ValueType_ = std::remove_reference_t<decltype(*std::begin(std::declval<R>()))>>
using is_range_of_pointers_t = std::enable_if_t<std::is_pointer_v<ValueType_> && !std::is_array_v<ValueType_>>;

// Overload for any range of pointers.
template <class R> struct default_resource_deleter<R, is_range_of_pointers_t<R>> {
    using type = default_delete_ptr_range<R>;
};

// Convenience alias.
template <class R> using default_resource_deleter_t = typename default_resource_deleter<R>::type;

// Type trait for checking whether type `R` is a valid deleter of type `D`.
template <class R, class D, class = void> struct is_valid_resource_deleter : std::false_type {
};
template <class R, class D> struct is_valid_resource_deleter<R, D, std::void_t<decltype(std::declval<D>()(std::declval<R &>()))>> : std::true_type {
};

// Convenience alias.
template <class R, class D> inline constexpr bool is_valid_resource_deleter_v = is_valid_resource_deleter<R, D>::value;

} // namespace utils_memory_internal

// Wrapper that holds and manages resource of type `Resource`. Equivalent of `unique_ptr` for non-pointer types.
//
// `unique_resource` tracks initialization status of its resource. The `Destructor` is called only when the resource is in initialized state.
// `unique_resource` constructed using default constructor is in uninitialized state. It becomes initialized when a valid resource is moved into it.
// Moving resource out or releasing it switches state to uninitialized.
//
// The API is based on unique_ptr rather than `unique_resource` from Library Fundamentals TS3.
template <class Resource, class Deleter = utils_memory_internal::default_resource_deleter_t<Resource>> class unique_resource
{
    // Check for errors in template parameters.
    // Use of intermediate constexprs results in nicer error messages.
    static constexpr bool deleter_for_resource_exists = !std::is_same_v<Deleter, utils_memory_internal::missing_type>;
    static_assert(deleter_for_resource_exists, "'Deleter' has not been specified and no default deleter exists for type 'Resource'.");
    static constexpr bool deleter_is_callable_with_resource_ref = utils_memory_internal::is_valid_resource_deleter_v<Resource, Deleter>;
    static_assert(deleter_is_callable_with_resource_ref, "Object of type 'Deleter' must be callable with argument of type 'Resource &'.");
    static constexpr bool resource_type_is_not_cvref = std::is_same_v<Resource, std::remove_cv_t<std::remove_reference_t<Resource>>>;
    static_assert(resource_type_is_not_cvref, "'Resource' must not be a reference or have const or volatile qualifier.");

    // Data members.

    Resource resource = {};
    bool initialized = false;

  public:
    // Initialize

    unique_resource() = default;

    template <class OtherResource> unique_resource(OtherResource &&other) : resource(std::forward<OtherResource>(other)), initialized(true) {}

    // Copy

    unique_resource(const unique_resource &) = delete;

    unique_resource &operator=(const unique_resource &) = delete;

    // Move

    template <class OtherDeleter>
    unique_resource(unique_resource<Resource, OtherDeleter> &&other) : resource(std::move(other.resource)), initialized(other.initialized)
    {
        other.initialized = false;
    }

    template <class OtherDeleter> unique_resource &operator=(unique_resource<Resource, OtherDeleter> &&other)
    {
        resource = std::move(other.resource);
        initialized = other.initialized;
        other.initialized = false;
    };

    // Destroy

    ~unique_resource()
    {
        if (initialized) {
            Deleter{}(resource);
        }
    }

    // Data access

    Resource &get()
    {
        assert(initialized);
        return resource;
    }

    const Resource &get() const
    {
        assert(initialized);
        return resource;
    }

    Resource &operator*()
    {
        assert(initialized);
        return resource;
    }

    const Resource &operator*() const
    {
        assert(initialized);
        return resource;
    }

    Resource *operator->()
    {
        assert(initialized);
        return &resource;
    }

    const Resource *operator->() const
    {
        assert(initialized);
        return &resource;
    }

    operator bool() const { return initialized; }

    // Operations

    Resource release()
    {
        Resource r = std::move(resource);
        initialized = false;
        return r;
    }

    void reset()
    {
        if (initialized) {
            Deleter{}(resource);
            initialized = false;
        }
    }

    template <class OtherResource> void reset(OtherResource &&other)
    {
        if (initialized) {
            Deleter{}(resource);
        }
        resource = std::forward<OtherResource>(other);
        initialized = true;
    }
};

// Creates `unique_resource<Resource, Deleter>` and initializes it with a resource constructed using specified arguments.
template <class Resource, class Deleter = utils_memory_internal::default_resource_deleter_t<Resource>, class... Tn>
inline unique_resource<Resource, Deleter> make_unique_resource(Tn &&... arg_n)
{
    return unique_resource<Resource, Deleter>(Resource(std::forward<Tn>(arg_n)...));
}

} // namespace systemverilog_plugin

#endif // SYSTEMVERILOG_PLUGIN_UTILS_MEMORY_H_
