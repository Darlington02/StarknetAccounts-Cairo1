#[account_contract]
mod AccountContract {
    use array::ArrayTrait;
    use array::SpanTrait;
    use box::BoxTrait;

    use src::Library::Account::Account;
    use src::Library::Account::Call;

    #[constructor]
    fn constructor(publicKey: felt252) {
        Account::initializer(publicKey);
        return ();
    }
    
    #[view]
    fn getPublicKey() -> felt252 {
        Account::get_public_key()
    }

    #[external]
    fn setPublicKey(newPublicKey: felt252) {
        Account::set_public_key(newPublicKey);
        return ();
    }

    #[external]
    fn isValidSignature(hash: felt252, signature: Span::<felt252>) -> felt252 {
        Account::is_valid_signature(hash, signature)
    }

    #[external]
    fn __validate__(call: Call) {
        let tx_info = starknet::get_tx_info().unbox();
        Account::is_valid_signature(tx_info.transaction_hash, tx_info.signature);
        return ();
    }

    #[external]
    fn __validate_declare__(class_hash: felt252) {
        let tx_info = starknet::get_tx_info().unbox();
        Account::is_valid_signature(tx_info.transaction_hash, tx_info.signature);
        return ();
    }

    #[external]
    fn __validate_deploy__(class_hash: felt252, salt: felt252, publicKey: felt252) {
        let tx_info = starknet::get_tx_info().unbox();
        Account::is_valid_signature(tx_info.transaction_hash, tx_info.signature);
        return ();
    }

    #[external]
    fn __execute__(call: Call) -> Span::<felt252> {
        Account::execute(call)
    }
}