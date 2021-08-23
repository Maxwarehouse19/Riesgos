from django.contrib.auth.decorators import login_required, user_passes_test
user_login_required = user_passes_test(lambda user: user.is_active, login_url='/')

def active_user_required(view_func):
    decorated_view_func = login_required(user_login_required(view_func))
    return decorated_view_func


