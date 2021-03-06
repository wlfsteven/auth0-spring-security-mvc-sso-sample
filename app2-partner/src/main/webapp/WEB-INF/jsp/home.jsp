<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Home Page</title>
    <link rel="stylesheet" type="text/css" href="/css/bootstrap.css">
    <link rel="stylesheet" type="text/css" href="/css/jumbotron-narrow.css">
    <link rel="stylesheet" type="text/css" href="/css/home.css">
    <link rel="stylesheet" type="text/css" href="/css/jquery.growl.css"/>
    <script src="http://code.jquery.com/jquery.js"></script>
    <script src="/js/jquery.growl.js" type="text/javascript"></script>
    <script src="//cdn.auth0.com/w2/auth0-7.2.1.js"></script>
</head>
<body>

<script type="text/javascript">
    // hide the page in case there is an SSO session (to avoid flickering)
    $('body').hide();
    var auth0Logout = function () {
        var options = {
            client_id: '${clientId}',
            returnTo: '${fn:replace(pageContext.request.requestURL, pageContext.request.requestURI, '')}${logoutEndpoint}'
        };
        return auth0.logout(options, {version: 'v2'});
    };
    <sec:authorize var="authenticated" access="isAuthenticated()" />
    // check SSO status
    var auth0 = new Auth0({
        domain: '${domain}',
        clientID: '${clientId}',
        callbackURL: '${fn:replace(pageContext.request.requestURL, pageContext.request.requestURI, '')}${loginCallback}'
    });
    auth0.getSSOData(function (err, data) {
        if (data && data.sso === true) {
            // have SSO session
            console.log('SSO: an Auth0 SSO session already exists');
            <c:choose>
                <c:when test="${authenticated}">
                    var loggedIn = true;
                    var loggedInUserId = '${user.userId}';
                </c:when>
                <c:otherwise>
                    var loggedIn = false;
                    var loggedInUserId = '';
                </c:otherwise>
            </c:choose>

            if (!loggedIn || (loggedInUserId !== data.lastUsedUserID)) {
                // have SSO session but no valid local session - auto-login user
                console.log("SSO Session but NOT locally authenticated ");
                auth0.login({
                    scope: 'openid name email picture',
                    state: '${state}',
                    connection: '${connection}'
                }, function (err) {
                    // this only gets called if there was a login error
                    console.error('Error logging in: ' + err);
                });
            } else {
                // have SSO session and valid user - display page
                console.log("SSO Session and locally authenticated ");
                $('body').show();
                $.growl({title: "Welcome  ${user.nickname}", message: "We hope you enjoy using the Partner Site!"});
                $("#logout").click(function(e) {
                    e.preventDefault();
                    $("#home").removeClass("active");
                    $("#logout").addClass("active");
                    auth0Logout();
                });
            }
        } else {
            <c:choose>
                <c:when test="${authenticated}">
                    console.log("NO SSO Session but locally authenticated ");
                    // user is logged in locally, but no SSO session exists -> log them out locally
                    window.location = '${fn:replace(pageContext.request.requestURL, pageContext.request.requestURI, '')}${logoutEndpoint}';

            </c:when>
                <c:otherwise>
                    // user is not logged in locally and no SSO session exists - send to the portal application's partner login page
                    console.log("NO SSO Session and NOT locally authenticated ");
                    window.location = '${partnerLoginUrl}?externalReturnUrl=' + encodeURIComponent(window.location);
            </c:otherwise>
            </c:choose>
        }
    });

</script>
<c:if test="${authenticated}">
    <div class="container">
        <div class="header clearfix">
            <nav>
                <ul class="nav nav-pills pull-right">
                    <li class="active" id="home"><a href="#">Home</a></li>
                    <li id="logout"><a href="#">Logout</a></li>
                </ul>
            </nav>
            <h3 class="text-muted">Partner Homepage</h3>
        </div>
        <div class="jumbotron">
            <h3>Hello ${user.name}!</h3>
            <p class="lead">Your username is: ${user.nickname} <sec:authentication property="principal.username"/></p>
            <p class="lead">Your nickname is: ${user.nickname}</p>
            <p class="lead">Your user id is: ${user.userId}</p>
            <p class="lead">
                <sec:authorize access="hasRole('ADMIN')">
                    <label>This line is only visible if you have ROLE_ADMIN</label>
                </sec:authorize>
            </p>
            <p class="lead">
                <sec:authorize access="hasRole('USER')">
                    <label>This line is only visible if you have ROLE_USER</label>
                </sec:authorize>
            </p>
            <p><img class="avatar" src="${user.picture}"/></p>
        </div>
        <div class="row marketing">
            <div class="col-lg-6">
                <h4>Subheading</h4>
                <p>Donec id elit non mi porta gravida at eget metus. Maecenas faucibus mollis interdum.</p>

                <h4>Subheading</h4>
                <p>Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Cras mattis consectetur purus sit amet
                    fermentum.</p>
            </div>

            <div class="col-lg-6">
                <h4>Subheading</h4>
                <p>Donec id elit non mi porta gravida at eget metus. Maecenas faucibus mollis interdum.</p>

                <h4>Subheading</h4>
                <p>Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Cras mattis consectetur purus sit amet
                    fermentum.</p>
            </div>
        </div>

        <footer class="footer">
            <p> &copy; 2016 Company Inc</p>
        </footer>
    </div>
</c:if>

</body>
</html>