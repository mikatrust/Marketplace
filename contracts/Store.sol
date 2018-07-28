pragma solidity ^0.4.24;

contract Store {

    //TBD : add quantity

    /* Let's make sure everyone knows who owns the store.*/
    address public store_owner;
    /* Let's give a name to the store */
    bytes32 public store_name;
    /* store balance */
    uint256 private store_balance;
    /* Well we sell products */
    mapping (uint256 => Product) public products;
    /* Well we have customers */
    //mapping (address => Customer) customers;
    /*Product index*/
    uint256 productNumber;
    /*Status of the product*/
    bool[] public productIsForSale;

    /* Product is a struct */
    struct Product {
      uint256 id;
      bytes32 name;
      bytes32 description;
      uint256 price;
    }

    // Events - publicize actions to external listeners
    // TBD
    /* Store Events */
    // TBD : change name of events, use "Log" same as event LogDepositMade(address accountAddress, uint amount);
    event StoreCreation(address owner, bytes32 storeName);
    event StoreDeletion(address owner, bytes32 soreName);
    event StoreAddProduct(address owner, bytes32 store_name, uint256 id, bytes32 name);
    event StoreRemoveProduct(address owner, bytes32 store_name, uint256 id, bytes32 name);
    event StoreUpdateProduct(address owner, bytes32 store_name, uint256 id, bytes32 name);
    event StorePurchaseProduct(address owner, bytes32 store_name, address customer, uint256 id, uint256 amount);
    event StoreUpdatePrice(address owner, bytes32 store_name, uint256 id, bytes32 name, uint256 price);

    /* Store modifier  */ /*TBD*/
    /*
      modifier verifyIsOwner (address _address) { require (msg.sender == owner);_;}
      modifier verifyCaller (address _address) { require (msg.sender == _address); _;}
      modifier paidEnough(uint _price) { require(msg.value >= _price); _;}
      modifier checkValue(uint _sku)
    */

    // Constructor, can receive one or many variables here; only one allowed
    // !!!! TBD ? : réaliser le register du store vers la marketplace dans le construteur du store ?
    constructor (/*bytes32 _name*/) public {
        /* Set the owner to the creator of this contract */
        bytes32 _name = "toto";
        store_owner = msg.sender;
        store_name = _name;
        store_balance = 0;
        emit StoreCreation(msg.sender, store_name);
    }

    function nProductsForSale () public returns (uint256 n){
      n = 0;
      uint256 i = 0;
      for(i=0;i<productIsForSale.length;i++){
        if(productIsForSale[i]==true)n=n+1;
      }
      return n;
    }

    function addProduct (bytes32 _name, bytes32 _description, uint256 _price) public returns (uint256 id) {
      //productNumber++;
      id = productIsForSale.length;
      Product memory product;
      product.name = _name;
      product.description = _description;
      product.price = _price;
      products[productNumber] = product;
      productIsForSale.push(true);
      productNumber++;
      emit StoreAddProduct(msg.sender, store_name, productNumber, _name);
      return id;
    }

    function removeProduct (uint256 id) public returns (bool) {
      bytes32 productRemovedName = products[id].name;
      delete products[id];
      productIsForSale[id] = false;
      emit StoreRemoveProduct(msg.sender, store_name, id, productRemovedName);
      return true;
    }

    function updateProduct (uint256 id, bytes32 _name, bytes32 _description, uint256 _price) public returns (bool){
      Product memory product;
      product.name = _name;
      product.description = _description;
      product.price = _price;
      products[id] = product;
      emit StoreUpdateProduct(msg.sender, store_name, id, _name);
      return true;
    }

    function updatePrice (uint256 id, uint256 _price) public returns (bool){
      Product memory product;
      product = products[id];
      product.price = _price;
      products[id] = product;
      emit StoreUpdatePrice(msg.sender, store_name, product.id, product.name, product.price);
      return true;
    }

    function purchaseProduct (uint256 id, uint amount) public payable returns (bool successful){
      //uint256 amount = 111;
      //TBD : checker que le transfert est supérieur au prix du produit
      //TBD if (balances[msg.sender] < amount) return false;
      //TBD balances[msg.sender] -= amount;
      store_balance += amount;
      //balances[receiver][coin] += amount;
      delete products[id];
      productIsForSale.push(false);
      emit StorePurchaseProduct(store_owner, store_name, msg.sender, id, amount);
      return true;
    }
/*
    function sendCoin(address receiver, uint amount, uint coin) returns(bool successful) {
        if (balances[msg.sender][coin] < amount) return false;
        balances[msg.sender][coin] -= amount;
        balances[receiver][coin] += amount;
        return true;
    }
*/

// Fallback function - Called if other functions don't match call or
// sent ether without data
// Typically, called when invalid data is sent
// Added so ether sent to this contract is reverted if the contract fails
// otherwise, the sender's money is transferred to contract
    function () {
      revert();
    }

    //function mortal
    //get fund
    //unregister from MarketPlace
}