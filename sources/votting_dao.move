module 0x0::votting_dao;

const EXP_ERR: u64 = 1;
const NOT_ELIGIBLE: u64 = 2;
const USER_RANKING_ERR:u64 = 3;

public enum Rank has drop, store{
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
    age: u64
}

public struct Dao has key {
    id: UID,
    name: std::string::String,
    decription: std::string::String,
    creator: address,  
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
    let description = b"A Decentralized Autonomous Community for Learning, Building and Innovation on Sui Network from Africa.";
    let new_dao = Dao { 
        id: object::new(ctx),
        name: std::string::utf8(b"Sui Hub Africa DAO"),
        decription: std::string::utf8(description),
        creator:  ctx.sender()
        };
    // let rank1 = Rank
    transfer::share_object(new_dao)
    // transfer::transfer(new_dao, ctx.sender())
}

public entry fun join_dao( dao: address, name: std::string::String, ctx: &mut TxContext){
    let create_membership = DoaMemeber {
        id: object::new(ctx),
        name,
        rank: Rank::User1,
        doa_address: dao,
        age: ctx.epoch()
    };

    transfer::public_transfer(create_membership, ctx.sender())
}

public entry fun upgrade_to_user2(membership: &mut DoaMemeber, ctx: &mut TxContext){
    // check for upgrade eligibilities
    // check if the user is lower
    assert!(&membership.rank == Rank::User1, USER_RANKING_ERR);
    let _2month = ctx.epoch() * 60;
    // check if the user is up to age
    assert!(membership.age >= _2month, 0);
    membership.rank = Rank::User2;
}

public entry fun upgrade_to_user3(membership: &mut DoaMemeber, ctx: &mut TxContext){
    // check for upgrade eligibilities
    // check if the user is lower
    assert!(&membership.rank == Rank::User2, USER_RANKING_ERR);
    let _5month = ctx.epoch() * 150;
    // check if the user is up to age
    assert!(membership.age >= _5month, 0);
    membership.rank = Rank::User3;
}

public entry fun votting(
     vote_for: bool, 
     proposal: &mut Proposal, 
     daoMember: &DoaMemeber, 
     ctx: &mut TxContext
     ){
    // check if the period has expired
    assert!(ctx.epoch() < proposal.exp, EXP_ERR);
    // check the votter has votted
    let mut i = 0;
    while (i < vector::length(&proposal.total))
    {
        if (proposal.total[i] == ctx.sender()) {
            abort 2
        };
        i = i + 1;
    };

    let _user1_rank = &Rank::User1;
    let _user2_rank = &Rank::User2;
    assert!(_user1_rank == &daoMember.rank || &daoMember.rank == _user2_rank, 5);

    if (vote_for){
        proposal.support = proposal.support + 1;
        vector::push_back(&mut proposal.total, ctx.sender());
    } else {
        proposal.not_supporting = proposal.not_supporting + 1;
        vector::push_back(&mut proposal.total, ctx.sender())
    };

    sui::event::emit(VoteEvent{
        msg: std::string::utf8(b"votted successfully")
    });


}

// public fun end_vote(proposal: &mut Proposal, member: &DoaMemeber, ctx: &mut TxContext)
// {
//     assert!(proposal.exp < ctx.epoch(), 3);
//     assert!(member.rank == Rank::User1, 4);
//     proposal.exp = ctx.epoch();
// }

public entry fun create_proposal( dao_id: address, member: &DoaMemeber, recipient: address, ctx: &mut TxContext) {
    // membership check
    assert!(member.doa_address == dao_id, 0);
    // eligibility check
    assert!(&member.rank == Rank::User1 || &member.rank == Rank::User2, NOT_ELIGIBLE);
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
