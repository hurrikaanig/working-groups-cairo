%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

struct WorkingGroup {
    subsidiaries: WorkingGroup*,
    subsidiaries_len: felt,
    coordinators: felt*,
    coordinators_len: felt,
    proposals: felt*,
    proposals_len: felt,
}

namespace Group {

    func init{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
    ) -> (working_group: WorkingGroup) {
        let subsidiaries: WorkingGroup* = alloc();
        let coordinators: felt* = alloc();
        let proposals: felt* = alloc();
        let (caller) = get_caller_address();
        coordinators[0] = caller;

        let working_group: WorkingGroup = WorkingGroup(
            subsidiaries = subsidiaries,
            subsidiaries_len = 0,
            coordinators = coordinators,
            coordinators_len = 1,
            proposals = proposals,
            proposals_len = 0,
        );
        return (working_group,);
    }

    func add_subsidiary{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _working_group: WorkingGroup
    ) -> (working_group: WorkingGroup, subsidiary: WorkingGroup) {
        alloc_locals;
        let subsidiaries: WorkingGroup* = alloc();
        let coordinators: felt* = alloc();
        let proposals: felt* = alloc();

        // add coordinators from parent
        memcpy(coordinators, _working_group.coordinators, _working_group.coordinators_len);
        
        let subsidiary: WorkingGroup = WorkingGroup(
            subsidiaries = subsidiaries,
            subsidiaries_len = 0,
            coordinators = coordinators,
            coordinators_len = _working_group.coordinators_len,
            proposals = proposals,
            proposals_len = 0,
        );

        assert _working_group.subsidiaries[_working_group.subsidiaries_len] = subsidiary;

        let new_group = WorkingGroup(
            subsidiaries = _working_group.subsidiaries,
            subsidiaries_len = _working_group.subsidiaries_len + 1,
            coordinators = _working_group.coordinators,
            coordinators_len = _working_group.coordinators_len,
            proposals = _working_group.proposals,
            proposals_len = _working_group.proposals_len,
        );

        return (new_group, subsidiary);
    }

    func remove_subsidiary{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _working_group: WorkingGroup, _index: felt
    ) -> (working_group: WorkingGroup) {
        alloc_locals;

        let new_subsidiaries: WorkingGroup* = alloc();
        memcpy(new_subsidiaries, _working_group.subsidiaries, _index);
        memcpy(new_subsidiaries + _index, _working_group.subsidiaries + _index, _working_group.subsidiaries_len - _index);

        let new_group = WorkingGroup(
            subsidiaries = new_subsidiaries,
            subsidiaries_len = _working_group.subsidiaries_len - 1,
            coordinators = _working_group.coordinators,
            coordinators_len = _working_group.coordinators_len,
            proposals = _working_group.proposals,
            proposals_len = _working_group.proposals_len,
        );
        return (new_group,);
    }

    func add_coordinator{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _working_group: WorkingGroup, _coordinator: felt
    ) -> (working_group: WorkingGroup) {
        alloc_locals;

        assert _working_group.coordinators[_working_group.coordinators_len] = _coordinator;

        let new_group = WorkingGroup(
            subsidiaries = _working_group.subsidiaries,
            subsidiaries_len = _working_group.subsidiaries_len,
            coordinators = _working_group.coordinators,
            coordinators_len = _working_group.coordinators_len + 1,
            proposals = _working_group.proposals,
            proposals_len = _working_group.proposals_len,
        );
        return (new_group,);
    }

    func remove_coordinator{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _working_group: WorkingGroup, _index: felt
    ) -> (working_group: WorkingGroup) {
        alloc_locals;
        let new_coordinators: felt* = alloc();
        memcpy(new_coordinators, _working_group.subsidiaries, _index);
        memcpy(new_coordinators + _index, _working_group.subsidiaries + _index, _working_group.subsidiaries_len - _index);

        let new_group = WorkingGroup(
            subsidiaries = _working_group.subsidiaries,
            subsidiaries_len = _working_group.subsidiaries_len,
            coordinators = new_coordinators,
            coordinators_len = _working_group.coordinators_len - 1,
            proposals = _working_group.proposals,
            proposals_len = _working_group.proposals_len,
        );
        return (new_group,);
    }

    func add_proposal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
        _working_group: WorkingGroup, _proposal: felt
    ) -> (working_group: WorkingGroup){
        assert _working_group.proposals[_working_group.proposals_len] = _proposal;

        let new_group = WorkingGroup(
            subsidiaries = _working_group.subsidiaries,
            subsidiaries_len = _working_group.subsidiaries_len,
            coordinators = _working_group.coordinators,
            coordinators_len = _working_group.coordinators_len,
            proposals = _working_group.proposals,
            proposals_len = _working_group.proposals_len + 1,
        );
        return (new_group,);
    }
}