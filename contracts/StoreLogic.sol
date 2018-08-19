pragma solidity ^0.4.24;

//P0
//A jouter dans le fichier pour installation :
//"npm install openzeppelin-solidity"

      import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
      import './MarketplaceLogic.sol';
      //import 'openzeppelin-solidity/contracts/payment/PullPayment.sol';

      contract StoreLogic
        {
          using SafeMath for uint256;

          //rapatrié de com
          address public owner;
          //bytes32 public name;

          uint256 count=0;
          /* Let's make sure everyone knows who owns the store.*/
          //address public store_owner;
          /* Let's give a name to the store */
          bytes32 public store_name;

          /* store balance TO REMOVE ??*/
          uint256 private store_balance;

          /*dataset to load ?*/
          string store_dataset;
          /*address of the marketplace to register*/
          address marketplace_address;
          /* Well we sell products */
          mapping (uint256 => Product) public products;
          /* Well we have customers */
          //mapping (address => Customer) customers;
          /*Product index*/
          uint256 public productNumber = 0;
          /*Status of the product*/
          bool[] public isForSale;

          /* Product is a struct */
          struct Product {
            uint256 id;
            bytes32 name;
            uint256 quantity;
            bytes32 description;
            uint256 price;
          }

          // Events - publicize actions to external listeners
          event LogCreate(bytes32 storeName, address byAddress);
          event LogDelete(bytes32 storeName, address byAddress); // not used yet
          event LogAddProduct(bytes32 storeName, uint256 id, bytes32 name);
          event LogRemoveProduct(bytes32 storeName, uint256 id, bytes32 name);
          event LogUpdatePrice(bytes32 storeName, uint256 id, uint256 oldPrice, uint256 newPrice);
          event LogUpdateQuantity(bytes32 storeName, uint256 id, uint256 oldQuantity, uint256 newQuantity);
          event LogUpdateDescription(bytes32 storeName, uint256 id, bytes32 oldDescription, bytes32 newDescription);
          event LogPurchaseProduct(uint256 id, uint256 quantity, uint256 totalPrice, address customerAddress);

            modifier forSale (uint256 _id)
            {
                require (_id >= productNumber && isForSale[_id] == true,
                  "Item is not ForSale."
                );
                _;
            }

            modifier enoughStock (uint256 _id, uint256 _quantity)
            {
                require (_quantity >= products[_id].quantity,
                  "Not enough stock."
                );
                _;
            }

            modifier paidEnough(uint256 _id, uint256 _quantity) {
              require ((msg.value >= ((products[_id].price).mul(_quantity))),
                "Not enough money."
              );
              _;
            }

            modifier giveBackChange(uint256 _id, uint256 _quantity) {
              //refund them after pay for item (why it is before, _ checks for logic before func)
              _;
              msg.sender.transfer(msg.value - products[_id].price * _quantity);
            }

          // !!!! TBD ? : réaliser le register du store vers la marketplace dans le construteur du store ?
          constructor (address _owner, bytes32 _name)
          public {
              owner = _owner;
              store_name = _name;

              //store_dataset = "_dataset";
              //marketplace_address = _marketplace;
              store_name = _name;
              emit LogCreate(store_name, msg.sender);
          }


          function dummy()
          public
          pure
          returns (uint)
          {
            return (42);
          }
/*
          function applyToMarketplace (address marketplaceAddr)
          public
          returns (uint256)
          {
            MarketplaceLogic myChoice = MarketplaceLogic(marketplaceAddr);
            return(myChoice.applyToMarketplace("toto"));
          }
*/
//store_name
          function nProductsForSale () public view returns (uint256 n){
            n = 0;
            uint256 i = 0;
            for(i=0;i<isForSale.length;i++){
              if(isForSale[i]==true)n=n+1;
            }
            return n;
          }

          function heartBeat ()
            public
            pure
            returns (uint256)
            {
            return uint256(2);
            }

          function useSub()
            public
            pure
            returns (uint256)
            {
              return uint256(10).sub(uint256(5));
            }


          function addProduct (bytes32 _name, uint256 _quantity, bytes32 _description, uint256 _price)
              public
              returns (uint)
            {
            //id = isForSale.length;
            uint id = productNumber;
            Product memory product;
            product.name = _name;
            product.quantity = _quantity;
            product.description = _description;
            product.price = _price;
            products[id] = product;
            isForSale.push(true);
            productNumber++;
            emit LogAddProduct(store_name, id, _name);
            return id;
          }

          function getProduct (uint256 id)
              public
              view
              returns (bytes32 name, uint256 quantity, bytes32 description, uint256 price)
          {
              require (isForSale[id]==true);
              Product memory p = products[id];
              return (p.name, p.quantity, p.description, p.price);
          }

          function removeProduct (uint256 id) public {
            emit LogRemoveProduct(store_name, id, products[id].name);
            delete products[id];
            isForSale[id] = false;
          }

          function updatePrice (uint256 id, uint256 _price) public {
            uint256 oldPrice = products[id].price;
            products[id].price = _price;
            emit LogUpdatePrice(store_name, id, oldPrice, _price);
          }

          function updateQuantity (uint256 id, uint256 _quantity) public {
            uint256 oldQuantity = products[id].quantity;
            products[id].quantity = _quantity;
            emit LogUpdateQuantity(store_name, id, oldQuantity, _quantity);
          }

          function updateDescription (uint256 id, bytes32 _description) public {
            bytes32 oldDescription = products[id].description;
            products[id].description = _description;
            emit LogUpdateDescription(store_name, id, oldDescription, _description);
          }
/*
          function purchaseProduct (uint256 id, uint256 quantity)
          public
          payable
          forSale (id)
          enoughStock (id, quantity)
          paidEnough(id, quantity)
          giveBackChange(id, quantity)
          {
            //update quantity in store
            products[id].quantity = products[id].quantity.sub(quantity);
            //put payment is escrow
            //asyncTransfer(owner, (products[id].price).mul(quantity));

            emit LogPurchaseProduct(id, quantity, (quantity.mul(products[id].price)), msg.sender);
          }
*/
/*
          function withdrawReceivedPayments ()
            public
            {
              withdrawPayments();
            }
*/
          function identicalProduct
            (uint256 _id1, bytes32 _name1, bytes32 _description1, uint256 _price1,
            uint256 _id2, bytes32 _name2, bytes32 _description2, uint256 _price2)
            public
            pure
            returns (bool isIdentical) {
              if ((_id1==_id2) && (_name1==_name2) && (_description1==_description2) && (_price1==_price2)) return true;
              else return false;
          }

      // Fallback function - Called if other functions don't match call or
      // sent ether without data
      // Typically, called when invalid data is sent
      // Added so ether sent to this contract is reverted if the contract fails
      // otherwise, the sender's money is transferred to contract
          function () public {
            revert();
          }

}
