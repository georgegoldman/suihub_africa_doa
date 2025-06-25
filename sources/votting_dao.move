module 0x0::votting_dao;

public enum Rank has store{
    User1,
    User2,
    User3
}

public enum VoteOption has copy, drop {
    VoteFor,
    VoteAgainst
}

public struct DoaMemeber has key, store {
    id: UID,
    name: std::string::String,
    rank: Rank,
    doa_address: address,
}

public struct Dao has key {
    id: UID,
    admin: address,  
}

public struct VoteEvent has copy, drop {
    msg: std::string::String,
}

public struct VOTTING_DAO has drop{}

public struct Proposal has key, store {
    id: UID,
    dao: address,
    support: u64,
    not_supporting: u64,
    exp: u64,
    total: vector<address>
}

fun init(_otw: VOTTING_DAO, ctx: &mut TxContext){

    let new_dao = Dao { 
        id: object::new(ctx), 
        admin:  ctx.sender()
        };
    transfer::transfer(new_dao, ctx.sender())
}

public fun join_dao(name: std::string::String, rank: Rank, dao: address, recipient: address, ctx: &mut TxContext){
    let create_membership = DoaMemeber {
        id: object::new(ctx),
        name,
        rank,
        doa_address: dao,
    };

    transfer::public_transfer(create_membership, recipient)
}

public fun votting(vote_option: VoteOption, proposal: &mut Proposal, votter_addr: address, ctx: &mut TxContext){
    // check if the period has expired
    assert!(ctx.epoch() < proposal.exp, 1);
    // check the votter has votted
    let mut i = 0;
    while (i < vector::length(&proposal.total))
    {
        if (proposal.total[i] == votter_addr) {
            abort 2
        };
        i = i + 1;
    };

    if (vote_option == VoteOption::VoteFor){
        proposal.support = proposal.support + 1;
        vector::push_back(&mut proposal.total, votter_addr);
    } else if (vote_option == VoteOption::VoteAgainst) {
        proposal.not_supporting = proposal.not_supporting + 1;
        vector::push_back(&mut proposal.total, votter_addr)
    };

    sui::event::emit(VoteEvent{
        msg: std::string::utf8(b"votted successfully")
    })
}

// public fun end_vote(proposal: &mut Proposal, member: &DoaMemeber, ctx: &mut TxContext)
// {
//     assert!(proposal.exp < ctx.epoch(), 3);
//     assert!(member.rank == Rank::User1, 4);
//     proposal.exp = ctx.epoch();
// }

public fun create_proposal(ctx: &mut TxContext, dao_id: address, member: &DoaMemeber, recipient: address) {
    assert!(member.doa_address == dao_id, 0);
    let new_proposal = Proposal {
        id: object::new(ctx),
        dao: dao_id,
        support: 0,
        not_supporting: 0,
        exp: ctx.epoch() + 7,
        total: vector::empty<address>(),
    };

    transfer::public_transfer(new_proposal, recipient);

}
