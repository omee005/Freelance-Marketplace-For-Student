module MyModule::FreelanceMarketplace {
    use aptos_framework::signer;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::vector;

    struct Job has store {
        description: vector<u8>,
        payment: Coin<AptosCoin>,
    }

    struct JobBoard has key {
        jobs: vector<Job>,
    }

    public entry fun init_job_board(account: &signer) {
        move_to(account, JobBoard { jobs: vector::empty<Job>() });
    }

    public entry fun post_job(client: &signer, description: vector<u8>, amount: u64) acquires JobBoard {
        let payment = coin::withdraw<AptosCoin>(client, amount);
        let job = Job {
            description,
            payment,
        };
        let board = borrow_global_mut<JobBoard>(signer::address_of(client));
        vector::push_back(&mut board.jobs, job);
    }

    public entry fun accept_job(student: &signer, client_addr: address, index: u64) acquires JobBoard {
        let board = borrow_global_mut<JobBoard>(client_addr);
        let job = vector::remove(&mut board.jobs, index);

        // ✅ Destructure job to move out payment safely
        let Job { payment, description: _ } = job;

        coin::deposit<AptosCoin>(signer::address_of(student), payment);
    }
}
