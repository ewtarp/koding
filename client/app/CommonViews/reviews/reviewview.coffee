class ReviewView extends KDView

  constructor:(options, data)->

    super

    @setClass "review-container"
    @createSubViews data
    @decorateCommentedState()
    @attachListeners()

  render:->
    @decorateCommentedState()

  createSubViews:(data)->

    @reviewList = new KDListView
      type          : "comments"
      itemClass     : ReviewListItemView
      delegate      : @
      lastToFirst   : yes
    , data

    @commentController        = new ReviewListViewController view: @reviewList
    @addSubView @commentForm  = new NewReviewForm delegate : @reviewList
    @addSubView @commentController.getView()
    @addSubView showMore      = new CommentViewHeader
      delegate        : @reviewList
      itemTypeString  : 'review'
    , data

    @reviewList.on "OwnCommentHasArrived", -> showMore.ownCommentArrived()
    @reviewList.on "ReviewIsDeleted", -> showMore.ownCommentDeleted()

    data.fetchRelativeReviews limit:3, after:'meta.createdAt', (err, reviews)=>
      for review in reviews.reverse()
        @reviewList.addItem review

    @reviewList.emit "BackgroundActivityFinished"

  attachListeners:->

    @reviewList.on "commentInputReceivedFocus", @bound "decorateActiveCommentState"

    @reviewList.on "CommentLinkReceivedClick", (event) =>
      @commentForm.commentInput.setFocus()

    @reviewList.on "CommentCountClicked", =>
      @reviewList.emit "AllCommentsLinkWasClicked"

  decorateNoCommentState:->
    @unsetClass "active-comment"
    @unsetClass "commented"
    @setClass "no-comment"

  decorateCommentedState:->
    @unsetClass "active-comment"
    @unsetClass "no-comment"
    @setClass "commented"

  decorateActiveCommentState:->
    @unsetClass "commented"
    @unsetClass "no-comment"
    @setClass "active-comment"

  decorateItemAsLiked:(likeObj)->
    if likeObj?.results?.likeCount > 0
      @setClass "liked"
    else
      @unsetClass "liked"
    @ActivityActionsView.setLikedCount likeObj
