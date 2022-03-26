pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";



contract Blog {
    string public name;
    address public owner;

    using Counters for Counters.Counter;
    Counters.Counter private _postIds;

    struct Post{
        uint id;
        string title;
        string content;
        bool published;
    }


    /* we create lookup table via mappings for posts by id and ipfs storage hash */
    mapping(uint => Post) private idToPost;
    mapping(string => Post ) private hashToPost;

    /* events facilitate comms btw contracts and user interface just like event list in js we can create event listeners in clients */
    event PostCreated(uint id, string title, string hash);
    event PostUpdated(uint id, string title, string hash, bool published);

    constructor (string memory _name){
        name = _name;//name of the blog assigned on deployment
        owner =  msg.sender; //the owner is the address dat sends/signs d transaction on deployment of contract
    }

    /*function to update name of the blog. */
    function updateName(string memory _name) public onlyOwner {
        name = _name;
    }

    /*transfer ownership of the blog/contract to the newowners address */
    function transferOwnership(address newowner) public onlyOwner {
        owner = newowner;
    }

    /* to fetch a single post by the posts id */
    function fetchPost (string memory hash) public view returns(Post memory){
        return hashToPost[hash];
    }

    /*creating a new post */
    function createPost (string memory title, string memory hash) public onlyOwner{
        require(bytes(hash).length > 0);
        require(bytes(title).length > 0);
        require(msg.sender != address(0x0));

        _postIds.increment();
        uint postId = _postIds.current();
        Post storage post = idToPost[postId];
        post.id = postId;
        post.title = title;
        post.content = hash;
        post.published = true;
        hashToPost[hash] = post;
        emit PostCreated(postId, title, hash);
    }

    function updatePost (uint postId,  string memory title, string memory hash, bool published) public onlyOwner{
        require(postId > 0 && postId <= _postIds.current());

        Post storage post = idToPost[postId];
        post.title = title;
        post.content = hash;
        post.published = published;
        hashToPost[hash] = post;
        idToPost[postId] = post;
        emit PostUpdated(post.id, title, hash, published);
    }

    function fetchPosts() public view returns(Post[] memory){
        uint itemCount = _postIds.current();
        uint currentIndex = 0;

        Post[] memory posts = new Post[](itemCount);
        for (uint i = 0; i < itemCount; i++) {
            uint currentId = i + 1;//cant start with a zero cos counters started with 1
            Post storage currentItem = idToPost[currentId];//looks up the post by the uint id or indexed integer
            posts[currentIndex] = currentItem;//puts in the post object by there index starting from zero into the list
            currentIndex += 1;//increases the index by 1 after each loop
        }
        return posts;
    }

    /*function tipPost(uint postId) public payable{
        require(postId > 0 && postId <= _postIds.current());

        Post storage post = idToPost[postId];
        address payable dogBoy = owner;
        address(dogBoy).transfer(msg.value);
    }*/

    /* this modifier means only the contract owner can */
    /* invoke the function */
    modifier onlyOwner() {
      require(msg.sender == owner);
    _;
  }

}