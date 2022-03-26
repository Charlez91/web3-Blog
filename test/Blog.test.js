const { expect } = require("chai");
const Blog = artifacts.require("Blog");

contract ('Blog', function(){
    let blog 

    before(async()=>{
        blog = await Blog.deployed();
    })

    it('it should create a post', async()=>{
        await blog.createPost("My first post", "12345");
        const posts = await blog.fetchPost("12345");

        expect(posts.title).to.equal("My first post");
    })

    it("should edit an existing post", async()=>{
        await blog.createPost("My second post", "12345");
        await blog.updatePost(1, "My updated post title", "1234567", true);

        const posts = await blog.fetchPost("1234567");
        expect(posts.title).to.equal("My updated post title");
    })

    it("should update the name of the contract", async function(){
        //const blogs =await Blog.deploy("Big Dog");
        //await blogs.deployed();
        expect(await blog.name()).to.equal("Dog Blog");

        await blog.updateName("Dog Blog Updated");
        expect(await blog.name()).to.equal("Dog Blog Updated");
    })
})
