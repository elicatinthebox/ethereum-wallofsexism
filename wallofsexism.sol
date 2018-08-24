pragma solidity ^0.4.21;

contract WallOfSexism {
    
    //set the owner
    address owner = msg.sender;
    
    //admins
    mapping (address => bool) private adminTeam;
    
    enum PostState {
        Pending,
        Approved,
        Refused
    }
    
    struct Post {
        address creatorAddr;
        string long_text;
        string ipfsLink;
        string otherLink;
        string whoSaidThat;
        PostState state;
        uint insertedAt;
        uint languageId;
        
    }
    
    Post[] private posts;
    
    /* LANGUAGE IDS
    0 = unknown
    1 = en 
    2 = es 
    3 = fr 
    4 = it 
    5 = de
    etc...
    */
    
    struct AdminActivity {
        address adminAddr;
        uint postId;
        PostState state;
        bool isNew;
        uint date;
    }
    
    AdminActivity[] public adminActivity;
    
    modifier isAdmin(){
        require(adminTeam[msg.sender] || msg.sender == owner);
        _;
    }
    
    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }
    
    ///@notice Owner can add or remove admins
    ///@param _targetAddress The address of the admin
    ///@param isEnabled enable or disable admin
    function manageAdmin(address _targetAddress, bool isEnabled)
    isOwner()
    public
    {
        adminTeam[_targetAddress] = isEnabled;
    }
    
    function addAdminPost(
        string _long_text,
        string _ipfsLink,
        string _otherLink,
        string _whoSaidThat,
        uint _languageId
        )
    isAdmin()
    public
    {
        uint id = posts.push(Post(msg.sender, _long_text, _ipfsLink, _otherLink, _whoSaidThat, PostState.Approved, now, _languageId)) - 1;
    
        adminActivity.push(AdminActivity(msg.sender, id, PostState.Approved, true, now));

    }
    
    function addPost(
        string _long_text,
        string _ipfsLink,
        string _otherLink,
        string _whoSaidThat,
        uint _languageId
        )
    public
    {
        posts.push(Post(msg.sender, _long_text, _ipfsLink, _otherLink, _whoSaidThat, PostState.Pending, now, _languageId));
    }
    
    function editPostState(uint _postId, PostState _postState)
    isAdmin()
    public
    {
        posts[_postId].state = _postState;
        adminActivity.push(AdminActivity(msg.sender, _postId, _postState, true, now));
    }
    
    function editPostLang(uint _postId, uint _languageId)
    isAdmin()
    public
    {
        posts[_postId].languageId = _languageId;
    }
    
    function getPost(uint _postId)
    isAdmin()
    view
    public
    returns(
        string long_text,
        string ipfsLink,
        string otherLink,
        string whoSaidThat,
        PostState state,
        uint insertedAt,
        uint languageId
        )
    {
        return (
            posts[_postId].long_text,
            posts[_postId].ipfsLink,
            posts[_postId].otherLink,
            posts[_postId].whoSaidThat,
            posts[_postId].state,
            posts[_postId].insertedAt,
            posts[_postId].languageId
            );
    }
    
    function getApprovedPost(uint _postId)
    view
    public
    returns(
        string long_text,
        string ipfsLink,
        string otherLink,
        uint insertedAt,
        uint languageId
        )
    {
        if(posts[_postId].state == PostState.Approved) {
        return (
            posts[_postId].long_text,
            posts[_postId].ipfsLink,
            posts[_postId].otherLink,
            posts[_postId].insertedAt,
            posts[_postId].languageId
            );
        }
        
        return (
            "not approved",
            "not approved",
            "not approved",
            posts[_postId].insertedAt,
            posts[_postId].languageId
        );
    }
    
}
