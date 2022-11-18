%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.WorkingGroup import (Group, WorkingGroup)

@external
func test_create_group{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    let (new_group) = Group.init();
    assert new_group.subsidiaries_len = 0;
    assert new_group.proposals_len = 0;
    assert new_group.coordinators_len = 1;
    return ();
}

@external
func test_add_subsidiary{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    let (group) = Group.init();

    let (new_group, subsidiary) = Group.add_subsidiary(group);

    assert new_group.subsidiaries[0] = subsidiary;
    assert new_group.subsidiaries_len = 1;
    assert subsidiary.coordinators[0] = new_group.coordinators[0];
    return ();
}

@external
func test_remove_subsidiary{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    let (group) = Group.init();

    let (new_group, subsidiary) = Group.add_subsidiary(group);

    let (remove_sub_group) = Group.remove_subsidiary(new_group, 0);

    assert remove_sub_group.subsidiaries_len = 0;
    return ();
}

@external
func test_add_coordinator{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    let (group) = Group.init();

    let (new_group) = Group.add_coordinator(group, 2);

    assert new_group.coordinators[1] = 2;
    assert new_group.coordinators_len = 2;
    return ();
}

@external
func test_remove_coordinators{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    let (group) = Group.init();

    let (new_group) = Group.add_coordinator(group, 2);

    let (remove_coor_group) = Group.remove_coordinator(new_group, 0);

    assert remove_coor_group.coordinators_len = 1;
    return ();
}