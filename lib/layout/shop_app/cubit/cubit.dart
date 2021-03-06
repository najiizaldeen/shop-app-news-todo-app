import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/layout/shop_app/cubit/states.dart';
import 'package:todo_app/models/shop_app/categories_model.dart';
import 'package:todo_app/models/shop_app/change_favorietes_model.dart';
import 'package:todo_app/models/shop_app/favorites_model.dart';
import 'package:todo_app/models/shop_app/home_model.dart';
import 'package:todo_app/models/shop_app/login_model.dart';
import 'package:todo_app/modules/shop_app/cateogries/cateogries_screen.dart';
import 'package:todo_app/modules/shop_app/favorites/favorites_screen.dart';
import 'package:todo_app/modules/shop_app/products/products_screen.dart';
import 'package:todo_app/modules/shop_app/settings/settings_screen.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'package:todo_app/shared/network/end_points.dart';
import 'package:todo_app/shared/network/remote/dio_helper.dart';

class ShopCubit extends Cubit<ShopStates> {
  ShopCubit() : super(ShopInitialState());
  static ShopCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  List<Widget> bottomScreens = [
    ProductsScreen(),
    CateogriesScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];
  void changeBottom(int index) {
    currentIndex = index;
    emit(ShopChangeBottomNaState());
  }

  Map<int, bool> favorites = {};
  HomeModel homeModel;
  void getHomeData() {
    emit(ShopLoadingHomeDataState());
    DioHelper.getData(
      token: token,
      url: HOME,
    ).then(
      (value) {
        homeModel = HomeModel.fromJson(value.data);
        // printFullText(homeModel.toString());
        //   print(homeModel.data.banners[0].image);
        homeModel.data.products.forEach(
          (element) {
            favorites.addAll({
              element.id: element.in_favorites,
            });
          },
        );
        print(favorites.toString());
        emit(ShopSuccessHomeDataState());
      },
    ).catchError(
      (error) {
        print(error.toString());
        emit(ShopErrorHomeDataState());
      },
    );
  }

  CategoriesModel categoriesModel;
  void getCategoriesModel() {
    DioHelper.getData(
      token: token,
      url: GET_Categories,
    ).then(
      (value) {
        categoriesModel = CategoriesModel.fromJson(value.data);

        emit(ShopSuccessCategoriesState());
      },
    ).catchError(
      (error) {
        print(error.toString());
        emit(ShopErrorCategoriesState());
      },
    );
  }

  ChangeFavorietesModel changeFavorietesModel;
  void changeFavorites(int productId) {
    favorites[productId] = !favorites[productId];
    emit(ShopChangeFavoritesState());

    DioHelper.postData(
      url: FAVORITES,
      data: {
        'product_id': productId,
      },
      token: token,
    ).then(
      (value) {
        changeFavorietesModel = ChangeFavorietesModel.fromJson(value.data);
        if (!changeFavorietesModel.status) {
          favorites[productId] = !favorites[productId];
        } else {
          getFavoritesModel();
        }
        emit(ShopSuccessChangeFavoritesState(changeFavorietesModel));
      },
    ).catchError(
      (error) {
        favorites[productId] = !favorites[productId];

        emit(ShopErrorChangeFavoritesState());
      },
    );
  }

  FavoritesModel favoritesModel;
  void getFavoritesModel() {
    emit(ShopLoadingGetFavoritesState());
    DioHelper.getData(
      token: token,
      url: FAVORITES,
    ).then(
      (value) {
        favoritesModel = FavoritesModel.fromJson(value.data);
        printFullText(value.data.toString());
        emit(ShopSuccessGetFavoritesState());
      },
    ).catchError(
      (error) {
        print(error.toString());
        emit(ShopErrorGetFavoritesState());
      },
    );
  }

  ShopLoginModel userModel;
  void getUserData() {
    emit(ShopLoadingUserDataState());
    DioHelper.getData(
      token: token,
      url: PROFILE,
    ).then(
      (value) {
        userModel = ShopLoginModel.fromJson(value.data);
        printFullText(userModel.data.name);
        emit(ShopSuccessUserDataState(userModel));
      },
    ).catchError(
      (error) {
        print(error.toString());
        emit(ShopErrorUserDataState());
      },
    );
  }

  void updateUserData({
    @required String name,
    @required String email,
    @required String phone,
  }) {
    emit(ShopLoadingUpdateUserState());
    DioHelper.putData(
      token: token,
      url: UPDATE_PROFILE,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
      },
    ).then(
      (value) {
        userModel = ShopLoginModel.fromJson(value.data);
        printFullText(userModel.data.name);
        emit(ShopSuccessUpdateUserState(userModel));
      },
    ).catchError(
      (error) {
        print(error.toString());
        emit(ShopErrorUpdateUserState());
      },
    );
  }
}
