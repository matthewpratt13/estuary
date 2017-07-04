module Estuary.Widgets.Text where

import Reflex
import Reflex.Dom
import Estuary.Tidal.Types
import Estuary.WebDirt.Foreign
import Estuary.Reflex.Container
import Estuary.Widgets.GeneralPattern
import Estuary.Reflex.Utility
import Data.Map
import Estuary.Widgets.Generic
import Control.Monad
import GHCJS.DOM.EventM
import Estuary.Protocol.JSON


{-
textGeneralContainer :: (MonadWidget t m, Show a) => Event t (GeneralPattern a) -> m (Dynamic t (GeneralPattern a), Event t (GeneralPattern a),Event t Hint)
textGeneralContainer delta = do
  let delta' = fmapMaybe getTextPattern delta
  x <- textInput $ def & textInputConfig_setValue .~ delta'
  let edits = fmap TextPattern $ _textInput_input x
  value <- mapDyn TextPattern $ _textInput_value x
  return (value,edits,never)


textSpecificContainer :: MonadWidget t m => ((GeneralPattern a) -> SpecificPattern) -> Event t SpecificPattern -> m (Dynamic t SpecificPattern, Event t SpecificPattern, Event t Hint)
textSpecificContainer f delta = textGeneralContainer delta >>= mapDyn (\(a,b,c) -> (f a,b,c))
 -}

textWidgetForPatternChain :: MonadWidget t m => Event t String -> m (Dynamic t String, Event t String)
textWidgetForPatternChain delta = do
  let attrs = constDyn $ ("class" =: "textInputToEndOfLine")
  x <- textInput $ def & textInputConfig_setValue .~ delta & textInputConfig_attributes .~ attrs
  let edits = _textInput_input x
  let value = _textInput_value x
  return (value,edits)

textPatternChainWidget :: MonadWidget t m => Zone -> Event t [Action ZoneValue] ->
  m (Dynamic t TransformedPattern,Event t (Action ZoneValue),Event t Hint)
textPatternChainWidget zone delta = divClass "textPatternChain" $ do
  let delta' = fmapMaybe justStructures $ fmapMaybe (justEditsInZone zone) delta
  let delta'' = fmapMaybe lastOrNothing $ fmapMaybe f delta'
  let deltaA = fmap (\(x,_,_)->x) delta''
  let deltaB = fmap (\(_,x,_)->x) delta''
  let deltaC = fmap (\(_,_,x)->x) delta''
  (aValue,aEvent) <- divClass "labelAndTextPattern" $ do
    divClass "textInputLabel" $ text "sound"
    textWidgetForPatternChain deltaA
  (bValue,bEvent) <- divClass "labelAndTextPattern" $ do
    divClass "textInputLabel" $ text "up"
    textWidgetForPatternChain deltaB
  (cValue,cEvent) <- divClass "labelAndTextPattern" $ do
    divClass "textInputLabel" $ text "vowel"
    textWidgetForPatternChain deltaC
  value <- combineDyn TextPatternChain aValue bValue
  value' <- combineDyn ($) value cValue
  let deltaUp = tagDyn value' $ leftmost [aEvent,bEvent,cEvent]
  let deltaUp' = fmap (Edit zone . Structure)
  return (value',deltaUp',never)
  where f (TextPatternChain x y z) = Just (x,y,z)
        f _ = Nothing


textWidget :: MonadWidget t m => Event t String -> m (Event t String,Event t String)
textWidget delta = divClass "textWidget" $ do
  let attrs = constDyn $ fromList [  ("class","textWidgetTextArea"), ("rows","5")]
  y <- textArea $ def & textAreaConfig_setValue .~ delta & textAreaConfig_attributes .~ attrs
  let edits = _textArea_input y
  evals <- button "eval"
  let evals' = tagDyn (_textArea_value y) evals
  return (edits,evals')


labelWidget :: MonadWidget t m => Zone -> Event t [Action ZoneValue] -> m (Event t (Action ZoneValue))
labelWidget z delta = divClass "textPatternChain" $ divClass "labelWidgetDiv" $ do
  let attrs = constDyn $ ("class" =: "labelWidgetTextInput")
  let delta' = fmapMaybe lastOrNothing $ fmapMaybe justLabelText $ fmapMaybe (justEditsInZone z) delta
  y <- textInput $ def & textInputConfig_setValue .~ delta''' & textInputConfig_attributes .~ attrs
  return $ fmap (Edit z . LabelText) $ _textInput_input y


{-
textPatternChain :: MonadWidget t m => Event t TransformedPattern -> m (Dynamic t TransformedPattern, Event t TransformedPattern, Event t Hint)
textPatternChain delta = do
  let (deltaA,tailA) = fmap g delta
  let (deltaB,tailB) = fmap g tailA
  let (deltaC,tailC) = fmap g tailB
  let (deltaD,_) = fmap g tailC
  (aValue,aEdit) <- textWidgetForPatternChain deltaA
  (bValue,bEdit) <- textWidgetForPatternChain deltaB
  (cValue,cEdit) <- textWidgetForPatternChain deltaC
  (dValue,dEdit) <- textWidgetForPatternChain deltaD
  abValue <- combineDyn (,) aValue bValue
  cdValue <- combineDyn (,) cValue dValue
  value <- combineDyn f abValue cdValue
  let edits = fmap (const ()) $ leftmost [aEdit,bEdit,cEdit,dEdit]

  (aValue,aEdit) <- textSpecificContainer (S) deltaA

  text "n"
  (bValue,bEdit) <- textSpecificContainer (N) deltaB
  text "up"
  (cValue,cEdit) <- textSpecificContainer (Up) deltaC
  text "vowel"
  (dValue,dEdit) <- textSpecificContainer (Vowel) deltaD
  value <- combineDyn

  where f (a,b) (c,d) = TextPatternChain a b c d
-}
