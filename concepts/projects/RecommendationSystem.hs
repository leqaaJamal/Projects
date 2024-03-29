import System.Random
import System.IO.Unsafe
randomZeroToX :: Int -> Int
randomZeroToX x= unsafePerformIO (getStdRandom (randomR (0, x)))
users = ["A","B","C","D","E"]
items=[ "item1" , "item2" , "item3" , "item4" , "item5" , "item6" ]
purchases =[("user1" , [ [ "item1" , "item2" , "item3" ] , [ "item1" , "item2" , "item4" ] ] ) ,
           ("user2" , [ [ "item2" , "item5" ] , [ "item4" , "item5" ] ] ),
           ("user3" , [ [ "item3" , "item2" ] ] ) ,
           ("user4" , [ ] )]
 
--recommend :: String -> [String] -> String


createEmptyFreqList :: [String]->[(String,[b])]
createEmptyFreqList [] = []
createEmptyFreqList (x:xs) = (x ,[]) : createEmptyFreqList xs 

-- I AM ASSUMING AN ITEM IS NOT FOUND MORE THAN ONCE IN THE SAME CART IF THIS IS WRONG
-- THEN I NEED TO UPDATE THE noOfOccurences METHOD ONLY 
contains ::Eq a =>[a]->a-> Bool
contains [] _ =False

contains (x:xs) a |x/=a =contains xs a
                  |otherwise = True 

 

--RETURNS THE NUMBER OF OCCURENCES OF 2 ITEMS TOGETHER IN A USER'S PURCHUASE HISTORY
noOfOccurences :: String ->String -> [[String]] -> Int
noOfOccurences _  _ [] =0
noOfOccurences item a  (x:xs ) | contains x a && contains x item = 1+ (noOfOccurences item a xs)
                               |otherwise =(noOfOccurences item a xs)
--returns the list of items purchuased with this item
itemsData :: String -> [String] -> [[String]]->[(String,Int)]
itemsData _ [] _ =[]
itemsData item (x:xs) carts = if x/=item && noOfOccurences item x carts > 0  then (x , noOfOccurences item x carts ) : itemsData item xs carts else itemsData item xs carts 

-- IT TAKES THE ITEMS ARRAY 2TIMES TO LOOP ON ONE AND PASS THE OTHER TO ITEMSDATA
allItemsData :: [String]->[String]->[[String]]-> [(String,[(String,Int)])]
allItemsData [] _ _ = []
allItemsData (x:xs) items carts = (x,itemsData x items carts) : allItemsData xs items carts


getAllUsersStats :: [(String,[[String]])]->[(String,[(String,[(String ,Int)])])]
getAllUsersStats [] =[]
getAllUsersStats ( (user,carts):xs )= (user , allItemsData items items carts ): getAllUsersStats xs

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--functional: generates a list of lists of common items between the current user and every other user 
purchasesIntersection :: Eq a => [(a,[(a,Int)])] -> [(a,[(a,[(a,Int)])])] -> [[(a,[(a,Int)])]]
purchasesIntersection _ [] = []
purchasesIntersection p (x:xs) =  [(generateListForUser p x)] ++ purchasesIntersection  p xs

--functional: generates a list of the intersection of items bought with each item bought by the current user and user X 
generateListForUser :: Eq a => [(a,[(a,Int)])] -> (a,[(a,[(a,Int)])]) -> [(a,[(a,Int)])]
generateListForUser [] _ = []
generateListForUser (i:is) x = putBack (getItem i (snd x)) ++ generateListForUser is x 

--functional: takes a list of repeated items and removes repetitions while incrementing the frequencies
putBack :: Eq a => [(a,[(a,Int)])] -> [(a,[(a,Int)])]
putBack [] = []
putBack (i:is) = (fst i,adjustFrequency (snd i) []):putBack is

--functional: generates a list of items bought with item# by current user and user X
getItem :: Eq a => (a,[(a,Int)]) -> [(a,[(a,Int)])] -> [(a,[(a,Int)])]
getItem i (u:us) = if fst i == fst u then if (snd u /= [] && snd i /= []) then [(fst u,snd u ++ snd i)] else [] else getItem i us

--functional [at last :)]: merges same elements of different frequencies 
adjustFrequency :: Eq a => [(a,Int)] -> [(a,Int)] -> [(a,Int)]
adjustFrequency [] acc = acc
adjustFrequency (x:xs) acc | length (getRepeated x xs) == 1 && occurs x acc == False = adjustFrequency xs (acc++[x])
						   | length (getRepeated x xs) == 1 && occurs x acc = adjustFrequency xs acc
						   | length (getRepeated x xs) > 1 && occurs x acc == False = adjustFrequency xs (acc++[sumFrequency (getRepeated x xs)])
						   | length (getRepeated x xs) > 1 && occurs x acc = adjustFrequency xs acc						   

--functional: given an item and a list of items, the function extracts identical items from the list and puts them in another list
getRepeated :: Eq a => (a,Int) -> [(a,Int)] -> [(a,Int)]
getRepeated (t,ts) [] = [(t,ts)]
getRepeated (t,ts) (z:zs) | t == fst z = z:getRepeated (t,ts) zs
						  | otherwise = getRepeated (t,ts) zs
						  
--functional: sums the frequencies of a list of identical items	and returns only a tuple containing the item and the sum			 
sumFrequency :: [(a,Int)] -> (a,Int)
sumFrequency (x:xs) = (fst x, sumFrequencyHelper x xs)

--functional: sums the frequencies of a list of identical items
sumFrequencyHelper :: (a,Int) -> [(a,Int)] -> Int
sumFrequencyHelper (t,ts) [] = ts
sumFrequencyHelper (t,ts) (z:zs) = snd z + sumFrequencyHelper (t,ts) zs 				 

--functional: decides whether the given tuple is a member of the input list or not
occurs :: Eq a => (a,Int) -> [(a,Int)] -> Bool
occurs _ [] = False
occurs (t,ts) (z:zs) | t == fst z = True
					 | otherwise = occurs (t,ts) zs
				
--functional: gets a compressed list of all items common between requested user and all the other users 				
freqListUsers :: String -> [(String,Int)]
freqListUsers s = adjustFrequency (flatten (purchasesIntersection (findUserPurchases s (getAllUsersStats purchases )) (findOthers s (getAllUsersStats purchases)))) []

--functional: puts all lists of common items generated by purchasesIntersection into a list
flatten :: [[(a,[(a,Int)])]] -> [(a,Int)]
flatten [] = []
flatten (x:xs) = flattenHelper x ++ flatten xs

--functional: read the comment above flatten
flattenHelper :: [(a,[(a,Int)])] -> [(a,Int)]
flattenHelper [] = []
flattenHelper (y:ys) = snd y ++ flattenHelper ys

--functional: finds the requested user's purchases as a list
findUserPurchases :: String -> [(String, [(String, [(String, Int)])])] -> [(String,[(String,Int)])]
findUserPurchases _ [] = []
findUserPurchases s (x:xs) | s == fst x = snd x
						   | otherwise = findUserPurchases s xs
						   
--functional: finds all users but the requested user and puts them in a list						   
findOthers :: String -> [(String, [(String, [(String, Int)])])] -> [(String,[(String,[(String,Int)])])]
findOthers _ [] = []
findOthers s (x:xs) | s /= fst x = x :findOthers s xs
					| otherwise = findOthers s xs
					

------------menna and leqaa
--dool btoo3 freqListItems
countitemsouter :: [String] -> [(String,[(String, Int)])] -> [(String,Int)]
countitemsouter [] _ = []
countitemsouter (x:xs) l= [(x,countitemsinner x l )] ++ countitemsouter xs l
countitemsinner :: String -> [(String,[(String,Int)])] -> Int
countitemsinner _ [] = 0
countitemsinner x ((y,y1):ys) = countitemsinnerhelper x y1 + countitemsinner x ys
countitemsinnerhelper :: String -> [(String,Int)] -> Int
countitemsinnerhelper _ [] =0
countitemsinnerhelper x ((z,z1):zs) = if x==z then   z1 + countitemsinnerhelper x zs else countitemsinnerhelper x zs 
del :: [(String,Int)] -> [(String,Int)]
del [] = []
del ((x,x1):xs) = if x1 /= 0 then (x,x1) : del xs else del xs
findUser :: String -> [(String,[(String,[(String,Int)])])] -> [(String,[(String,Int)])]
findUser _ [] = []
findUser s ((x,x1):xs) | s==x = x1
					   | otherwise = findUser s xs
freqListItems :: String -> [(String,Int)]
freqListItems s = del ( countitemsouter items ( findUser s (getAllUsersStats purchases) ) )
-- dool btoo3 feqlistcart
findItem :: String -> [(String,[(String,Int)])] -> [(String,Int)]
findItem _ []=[]
findItem s ((item,list):lists)= if item ==s then list else findItem s lists 
findItemSS :: String -> [String] -> [(String,Int)]
findItemSS _ []=[]
findItemSS s (cart:carts) = findItem cart (findUser s (getAllUsersStats purchases)) ++ findItemSS s carts 
sumfinallist :: [(String,Int)] -> [(String,Int)]
sumfinallist [] =[]
sumfinallist ((x,x1):xs) = [(x,x1+searchsameitem x xs)]++ sumfinallist(deleteall x xs)

deleteall :: String -> [(String,Int)] -> [(String,Int)]
deleteall _ [] = []
deleteall s ((x,x1):xs) | s == x = deleteall s xs
						| otherwise = (x,x1):deleteall s xs

searchsameitem :: String -> [(String,Int)] -> Int
searchsameitem _ []=0
searchsameitem x ((y,y1):ys) | x==y = y1 + searchsameitem x ys
							 | otherwise = searchsameitem x ys

sumofboth :: [(String,Int)] -> [(String,Int)] ->[(String,Int)] --awl wa7ed bta3 freqlistitems mn countiouter wl tany freqlistcart wl talet l total
sumofboth [] _ = []
sumofboth ((x,x1):xs) l = (x,(search x l + x1)):sumofboth xs l 

search :: String -> [(String,Int)] -> Int
search _ [] = 0
search x ((y,y1):ys) | x == y =y1
					 |otherwise = search x ys

freqListCart:: String ->[String] -> [(String, Int)]
freqListCart user l = sumfinallist( findItemSS user l )
freqListCartAndItems :: String -> [String] -> [(String,Int)]
freqListCartAndItems s l =  del ( sumofboth (countitemsouter items ( findUser s (getAllUsersStats purchases) ) ) (freqListCart s l ) )
--------------------------------------------------------menna w leqaa tany ya fashalaa					
recommendEmptyCart :: String -> String						
recommendEmptyCart s | length (recommendEmptyCartHelper (freqListItems s) ) ==0 = " "
                     | otherwise= recommendEmptyCartHelper (freqListItems s) !! randomZeroToX ( length (recommendEmptyCartHelper (freqListItems s) )-1 )
recommendEmptyCartHelper  :: [(String,Int)] -> [String]
recommendEmptyCartHelper []=[]
recommendEmptyCartHelper ((x,x1):xs) = recommendEmptyCartHelper1 x x1 ++ recommendEmptyCartHelper xs
recommendEmptyCartHelper1 :: String -> Int -> [String]
recommendEmptyCartHelper1 _ 0 = []
recommendEmptyCartHelper1 x x1= x:recommendEmptyCartHelper1 x (x1-1)	
recommendBasedOnItemsInCart :: String -> [String] -> String
recommendBasedOnItemsInCart s l = recommendEmptyCartHelper (freqListCartAndItems s l) !! randomZeroToX (length (recommendEmptyCartHelper (freqListCartAndItems s l))-1)

recommendBasedOnUsers :: String -> String
recommendBasedOnUsers s 
                         | length (freqListUsers s) ==0 = " "
					     | otherwise = recommendEmptyCartHelper (freqListUsers s ) !! randomZeroToX (length (recommendEmptyCartHelper (freqListUsers s ))-1)

recommend :: String -> [String] -> String
recommend s []  
               | (recommendBasedOnUsers s) ==" " && (recommendEmptyCart s) ==" " =items !! randomZeroToX (length items)
			   |(recommendBasedOnUsers s ) ==" " = recommendEmptyCart s
			   |(recommendEmptyCart s) == " " =recommendBasedOnUsers s
			   |otherwise = [(recommendBasedOnUsers s) ,(recommendEmptyCart s) ] !! randomZeroToX 1
recommend s l |  (recommendBasedOnUsers s) ==" "  &&  ( recommendBasedOnItemsInCart s l) ==" "  = items !! randomZeroToX (length items)
			  | (recommendBasedOnUsers s)== " " = recommendBasedOnItemsInCart s l
			  | otherwise = [(recommendBasedOnUsers s), (recommendBasedOnItemsInCart s l)] !! randomZeroToX 1


--recommend s l = [(recommendBasedOnUsers s),(recommendBasedOnItemsInCart s l )] !! randomZeroToX 1