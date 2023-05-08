#[derive(Drop, Serde)]
struct Call {
    to: felt252,
    selector: felt252,
    calldata: Array::<felt252>,
}

trait IAccount {
    fn initializer(_public_key: felt252);

    fn assert_only_self();

    fn get_public_key() -> felt252;

    fn set_public_key(new_public_key: felt252);

    fn is_valid_signature(hash: felt252, signature: Span::<felt252>) -> felt252;

    fn execute(call: Call) -> Span<felt252>;

    fn _call_contract(call: Call) -> Span::<felt252>;
}

#[account_contract]
mod Account {
    use ecdsa::check_ecdsa_signature;
    use starknet::get_contract_address;
    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use starknet::ContractAddressZeroable;
    use zeroable::Zeroable;
    use starknet::get_tx_info;
    use starknet::VALIDATED;
    use box::BoxTrait;
    use starknet::call_contract_syscall;
    use serde::Serde;
    use serde::ArraySerde;
    use array::ArrayTrait;
    use array::SpanTrait;
    use option::OptionTrait;

    use super::Call;
    use super::IAccount;

    struct Storage {
        account_public_key: felt252,
    }
    
    impl Account of IAccount {
        fn initializer(_public_key: felt252) {
            account_public_key::write(_public_key);
            return ();
        }
        
        // GUARDS
        fn assert_only_self() {
            let self = get_contract_address();
            let caller = get_caller_address();
            assert(self == caller, 'caller is not account');
            return ();
        }

        fn get_public_key() -> felt252 {
            account_public_key::read()
        }

        fn set_public_key(new_public_key: felt252) {
            Account::assert_only_self();
            account_public_key::write(new_public_key);
            return ();
        }

        fn is_valid_signature(hash: felt252, signature: Span::<felt252>) -> felt252 {
            assert(signature.len() == 2_u32, 'Invalid signature length!');
            let public_key = account_public_key::read();
            let sig_r = signature[0_u32];
            let sig_s = signature[1_u32];

            let is_valid = check_ecdsa_signature(hash, public_key, *sig_r, *sig_s);

            assert(is_valid, 'invalid signature!');
            VALIDATED
        }

        fn execute(call: Call) -> Span::<felt252> {
            // check caller is not zero
            let caller = get_caller_address();
            assert(caller.is_zero(), 'ACCOUNT: reentrant call');
            // check tx version
            let tx_info = get_tx_info().unbox();
            assert(tx_info.version != 0, 'invalid txn version!');
            
            Account::_call_contract(call)
        }

        fn _call_contract(call: Call) -> Span::<felt252> {
            Call {to, selector, calldata} = call;
            call_contract_syscall(
                address: to,
                entry_point_selector: selector,
                calldata: calldata.span()
            ).unwrap_syscall()
        }
    }

    fn initializer(_public_key: felt252) {
        Account::initializer(_public_key);
        return ();
    }

    fn get_public_key() -> felt252 {
        Account::get_public_key()
    }

    fn set_public_key(new_public_key: felt252) {
        Account::set_public_key(new_public_key);
        return ();
    }

    fn is_valid_signature(hash: felt252, signature: Span::<felt252>) -> felt252 {
        Account::is_valid_signature(hash, signature)
    }

    fn execute(call: Call) -> Span::<felt252> {
        Account::execute(call)
    }

    // *********** SERDE ************* //
    impl CallSerde of Serde::<Call> {
        fn serialize(ref serialized: Array::<felt252>, input: Call) {
            Serde::<felt252>::serialize(ref serialized, input.to);
            Serde::<felt252>::serialize(ref serialized, input.selector);
            Serde::<Array::<felt252>>::serialize(ref serialized, input.calldata);
        }

        fn deserialize(ref serialized: Span::<felt252>) -> Option::<Call> {
            Option::Some(
               Call {
                    to: serde::Serde::<felt252>::deserialize(ref serialized)?,
                    selector: serde::Serde::<felt252>::deserialize(ref serialized)?,
                    calldata: serde::Serde::<Array::<felt252>>::deserialize(ref serialized)?,
               } 
            )
        }
    }
}